module HTS
  class Bam < Hts
    # High-level mpileup iterator over multiple BAM/CRAM inputs.
    # Yields an Array of Pileup::Column (one per input) for each position.
    # Columns contain the same Pileup::Alignment objects as single-input pileup;
    # use Alignment#base, #base_qual, and #qname in hot paths before falling back
    # to Alignment#record.
    class Mpileup
      include Enumerable(Array(HTS::Bam::Pileup::Column))

      # Per-input user data passed to the C callback
      struct InputData
        getter htsfp : LibHTS::HtsFile*
        getter hdr : LibHTS::SamHdrT*
        getter itr : LibHTS::HtsItrT*

        def initialize(@htsfp : LibHTS::HtsFile*, @hdr : LibHTS::SamHdrT*, @itr : LibHTS::HtsItrT*)
        end
      end

      @bams : Array(Bam)
      @iter : LibHTS::BamMplpT?
      @cb : LibHTS::BamPlpAutoF? # keepalive
      @data_blocks : Array(Pointer(InputData)) = [] of Pointer(InputData)
      @data_array : Pointer(Pointer(Void))? # pointer to array of per-input data pointers
      @itrs : Array(LibHTS::HtsItrT*) = [] of LibHTS::HtsItrT*
      @idxs : Array(LibHTS::HtsIdxT) = [] of LibHTS::HtsIdxT
      @n_inputs : Int32
      @maxcnt : Int32?
      @overlaps : Bool

      # Open an Mpileup iterator with block (RAII style)
      def self.open(inputs : Array(Bam), maxcnt : Int32? = nil, overlaps : Bool = false, *, region : String? = nil, regions : Array(String)? = nil, &)
        mpileup = new(inputs, maxcnt, overlaps, region: region, regions: regions)
        begin
          yield mpileup
        ensure
          mpileup.close
        end
      end

      # Open an Mpileup iterator using keyword arguments.
      def self.open(inputs : Array(Bam), *, maxcnt : Int32? = nil, overlaps : Bool = false, region : String? = nil, regions : Array(String)? = nil, &)
        open(inputs, maxcnt, overlaps, region: region, regions: regions) { |mpileup| yield mpileup }
      end

      # Accept Array(Bam). If region is set, it uses SAM-style 1-based inclusive
      # coordinates and each input must already have an index loaded. If regions
      # is set, htslib's multi-region iterator is used and overlapping records
      # are returned once.
      def initialize(inputs : Array(Bam), @maxcnt : Int32? = nil, overlaps : Bool = false, *, region : String? = nil, regions : Array(String)? = nil)
        raise ArgumentError.new("inputs must not be empty") if inputs.empty?

        @bams = inputs
        @n_inputs = inputs.size
        @overlaps = overlaps

        validate_regions!(region, regions)

        begin
          # Build per-input data blocks
          @data_blocks = Array(Pointer(InputData)).new(@n_inputs)
          @bams.each do |bam|
            itr = build_iterator(bam, region, regions)
            block = Pointer(InputData).malloc(1)
            block.value = InputData.new(
              bam.to_unsafe,
              bam.header.to_unsafe,
              itr
            )
            @data_blocks << block
          end

          # Make contiguous array of void* pointers to pass to bam_mplp_init
          data_array = Pointer(Pointer(Void)).malloc(@n_inputs)
          @data_array = data_array
          i = 0
          while i < @n_inputs
            # Store as void*
            data_array[i] = @data_blocks[i].as(Void*)
            i += 1
          end

          # Shared callback used for all inputs
          cb = ->(data : Void*, b : LibHTS::Bam1T*) : LibC::Int {
            id = data.as(Pointer(InputData)).value
            if id.itr.null?
              r = LibHTS.sam_read1(id.htsfp, id.hdr, b)
              r >= 0 ? 0 : -1
            else
              r = LibHTS2.sam_itr_next(id.htsfp, id.itr, b)
              r >= 0 ? 0 : -1
            end
          }
          @cb = cb

          iter = LibHTS.bam_mplp_init(@n_inputs, cb, data_array.as(Void**))
          raise "bam_mplp_init failed" if iter.nil? || iter.as(Void*).null?
          @iter = iter

          if cnt = @maxcnt
            LibHTS.bam_mplp_set_maxcnt(iter, cnt)
          end
          if @overlaps
            rc = LibHTS.bam_mplp_init_overlaps(iter)
            raise "bam_mplp_init_overlaps failed" if rc < 0
          end
        rescue ex
          close
          raise ex
        end
      end

      # Iterate and yield per-position columns array (aligned by tid,pos across inputs)
      def each(& : Array(HTS::Bam::Pileup::Column) ->) : Nil
        return unless iter = @iter

        tid = 0
        pos = 0_i64
        # Allocate GC-managed buffers for htslib output
        n_plp = Pointer(Int32).malloc(@n_inputs)
        plp_arr = Pointer(Pointer(LibHTS::BamPileup1T)).malloc(@n_inputs)

        loop do
          rc = LibHTS.bam_mplp64_auto(iter, pointerof(tid), pointerof(pos), n_plp, plp_arr)
          # Distinguish error from normal EOF
          raise "bam_mplp64_auto failed" if rc < 0
          break if rc == 0

          cols = Array(HTS::Bam::Pileup::Column).new(@n_inputs)
          s = 0
          while s < @n_inputs
            count = n_plp[s]
            # Defensive check against invalid counts
            raise "Invalid pileup count: #{count} (input #{s})" if count < 0

            base_ptr = plp_arr[s]
            if count == 0 || base_ptr.null?
              cols << HTS::Bam::Pileup::Column.new(tid, pos, [] of HTS::Bam::Pileup::Alignment, @bams[s].header)
            else
              aligns = Array(HTS::Bam::Pileup::Alignment).new(count)
              i = 0
              while i < count
                aligns << HTS::Bam::Pileup::Alignment.new(base_ptr + i, @bams[s].header)
                i += 1
              end
              cols << HTS::Bam::Pileup::Column.new(tid, pos, aligns, @bams[s].header)
            end
            s += 1
          end

          yield cols
        end
      end

      def close : Nil
        if iter = @iter
          LibHTS.bam_mplp_destroy(iter)
          @iter = nil
        end
        @itrs.each { |itr| LibHTS.hts_itr_destroy(itr) unless itr.null? }
        @itrs.clear
        @idxs.each { |idx| LibHTS.hts_idx_destroy(idx) unless idx.null? }
        @idxs.clear
        # Note: @data_blocks and @data_array are GC-managed (via Pointer.malloc)
        # and will be automatically freed by the GC.
      end

      def finalize
        close
      end

      private def validate_regions!(region : String?, regions : Array(String)?) : Nil
        raise ArgumentError.new("region and regions cannot both be specified") if region && regions
        raise ArgumentError.new("region must not be empty") if region && region.empty?
        return unless region_list = regions

        raise ArgumentError.new("regions must not be empty") if region_list.empty?
        region_list.each_with_index do |reg, index|
          raise ArgumentError.new("regions[#{index}] must not be empty") if reg.empty?
        end
      end

      private def build_iterator(bam : Bam, region : String?, regions : Array(String)?) : LibHTS::HtsItrT*
        return Pointer(LibHTS::HtsItrT).null if region.nil? && regions.nil?

        unless bam.index_loaded?
          raise Bam::MissingIndexError.new("Region mpileup requires an index for #{bam.file_name}. Open the BAM/CRAM with a matching index first.")
        end

        idx = bam.load_index
        raise Bam::MissingIndexError.new("Region mpileup requires an index for #{bam.file_name}. Open the BAM/CRAM with a matching index first.") if idx.null?

        itr =
          if region_list = regions
            query_multi_region_iterator(idx, bam, region_list)
          elsif single_region = region
            LibHTS.sam_itr_querys(idx, bam.header, single_region)
          else
            Pointer(LibHTS::HtsItrT).null
          end
        if itr.null?
          LibHTS.hts_idx_destroy(idx)
          target = regions || region
          raise Bam::QueryError.new("Failed to create an iterator for region #{target.inspect} in #{bam.file_name}. Check the region syntax, that the reference exists in the header, and that the index matches the file.")
        end

        @idxs << idx
        @itrs << itr
        itr
      end

      private def query_multi_region_iterator(idx : LibHTS::HtsIdxT, bam : Bam, regions : Array(String)) : LibHTS::HtsItrT*
        regarray = Pointer(LibC::Char*).malloc(regions.size)
        regions.each_with_index do |reg, index|
          regarray[index] = reg.to_unsafe
        end
        LibHTS.sam_itr_regarray(idx, bam.header, regarray, regions.size.to_u32)
      end
    end
  end
end
