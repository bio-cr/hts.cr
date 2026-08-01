module HTS
  class Bam < Hts
    # High-level mpileup iterator over multiple BAM/CRAM inputs.
    # Yields a zero-copy Position view for each genomic position. A Position is an
    # ordered collection of Pileup::Column views (one per input); index it with
    # position[i] or iterate it. Nothing is allocated per position, and Alignment
    # values are constructed lazily only for the reads the consumer touches, so it
    # matches the C mpileup hot-path cost. See Pileup::Column's borrowing contract.
    class Mpileup
      # Per-input user data passed to the C callback
      struct InputData
        getter htsfp : LibHTS::HtsFile*
        getter hdr : LibHTS::SamHdrT*
        getter itr : LibHTS::HtsItrT*
        getter filter : Pileup::Filter

        def initialize(@htsfp : LibHTS::HtsFile*, @hdr : LibHTS::SamHdrT*, @itr : LibHTS::HtsItrT*,
                       @filter : Pileup::Filter)
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
      def self.open(inputs : Array(Bam), maxcnt : Int32? = nil, overlaps : Bool = false, *,
                    region : String? = nil, regions : Array(String)? = nil,
                    filter : Pileup::Filter = Pileup::Filter.new, &)
        mpileup = new(inputs, maxcnt, overlaps, region: region, regions: regions, filter: filter)
        begin
          yield mpileup
        ensure
          mpileup.close
        end
      end

      # Open an Mpileup iterator using keyword arguments.
      def self.open(inputs : Array(Bam), *, maxcnt : Int32? = nil, overlaps : Bool = false,
                    region : String? = nil, regions : Array(String)? = nil,
                    filter : Pileup::Filter = Pileup::Filter.new, &)
        open(inputs, maxcnt, overlaps, region: region, regions: regions, filter: filter) { |mpileup| yield mpileup }
      end

      # Accept Array(Bam). If region is set, it uses SAM-style 1-based inclusive
      # coordinates and each input must already have an index loaded. If regions
      # is set, htslib's multi-region iterator is used and overlapping records
      # are returned once. `filter` applies the same read-level filtering as
      # single-input Pileup (see Pileup::Filter).
      def initialize(inputs : Array(Bam), @maxcnt : Int32? = nil, overlaps : Bool = false, *,
                     region : String? = nil, regions : Array(String)? = nil,
                     filter : Pileup::Filter = Pileup::Filter.new)
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
              itr,
              filter
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
            HTS::Bam::Mpileup.next_record(id, b)
          }
          @cb = cb

          iter = LibHTS.bam_mplp_init(@n_inputs, cb, data_array.as(Void**))
          raise MpileupError.new("bam_mplp_init failed") if iter.nil? || iter.as(Void*).null?
          @iter = iter

          if cnt = @maxcnt
            LibHTS.bam_mplp_set_maxcnt(iter, cnt)
          end
          if @overlaps
            rc = LibHTS.bam_mplp_init_overlaps(iter)
            raise MpileupError.new("bam_mplp_init_overlaps failed") if rc < 0
          end
        rescue ex
          close
          raise ex
        end
      end

      # A zero-copy view of one genomic position across all inputs. It is an
      # ordered collection of Pileup::Column views (one per input) sharing the
      # same tid/pos. It holds only pointers into htslib's current pileup buffer;
      # nothing is allocated per position and per-read Alignment values are built
      # lazily only for the columns the consumer touches.
      #
      # BORROWING CONTRACT: a Position, its Columns, and any Alignment obtained
      # from them are valid ONLY during the current iteration step. To retain data
      # across positions, read the copied-out scalars (Alignment#base, #base_qual,
      # #query_pos) or call Alignment#record.
      struct Position
        getter tid : Int32
        getter pos : Int64
        @n_plp : Pointer(Int32)
        @plp : Pointer(Pointer(LibHTS::BamPileup1T))
        @headers : Array(Bam::Header)
        @n_inputs : Int32

        def initialize(@tid : Int32, @pos : Int64, @n_plp : Pointer(Int32),
                       @plp : Pointer(Pointer(LibHTS::BamPileup1T)),
                       @headers : Array(Bam::Header), @n_inputs : Int32)
        end

        # Number of inputs (files) at this position.
        def size : Int32
          @n_inputs
        end

        # Number of inputs (files) at this position.
        def count : Int32
          @n_inputs
        end

        # Count input columns matching the block without materializing an Array.
        def count(& : HTS::Bam::Pileup::Column -> Bool) : Int32
          matched = 0
          each do |column|
            matched += 1 if yield column
          end
          matched
        end

        # Column view for one input.
        def [](input : Int32) : HTS::Bam::Pileup::Column
          raise IndexError.new("input index #{input} out of range 0...#{@n_inputs}") unless 0 <= input < @n_inputs
          count = @n_plp[input]
          raise MpileupError.new("Invalid pileup count: #{count} (input #{input})") if count < 0
          HTS::Bam::Pileup::Column.new(@tid, @pos, @plp[input], count, @headers[input])
        end

        # Raw pileup depth for one input at this position (before per-base filters).
        def depth(input : Int32) : Int32
          raise IndexError.new("input index #{input} out of range 0...#{@n_inputs}") unless 0 <= input < @n_inputs
          count = @n_plp[input]
          raise MpileupError.new("Invalid pileup count: #{count} (input #{input})") if count < 0
          count
        end

        # Iterate the per-input Column views.
        def each(& : HTS::Bam::Pileup::Column ->) : Nil
          i = 0
          while i < @n_inputs
            yield self[i]
            i += 1
          end
        end
      end

      # Iterate and yield a zero-copy Position view per genomic position. The view
      # is valid only for the duration of the block (see Position's contract).
      def each(& : Position ->) : Nil
        return unless iter = @iter

        headers = @bams.map(&.header)
        tid = 0
        pos = 0_i64
        n_plp = Pointer(Int32).malloc(@n_inputs)
        plp_arr = Pointer(Pointer(LibHTS::BamPileup1T)).malloc(@n_inputs)

        loop do
          rc = LibHTS.bam_mplp64_auto(iter, pointerof(tid), pointerof(pos), n_plp, plp_arr)
          raise MpileupError.new("bam_mplp64_auto failed") if rc < 0
          break if rc == 0

          yield Position.new(tid, pos, n_plp, plp_arr, headers, @n_inputs)
        end
      end

      # Count mpileup positions by consuming this iterator.
      def count : Int32
        total = 0
        each { total += 1 }
        total
      end

      # Count mpileup positions matching the block by consuming this iterator.
      def count(& : Position -> Bool) : Int32
        matched = 0
        each do |position|
          matched += 1 if yield position
        end
        matched
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

      protected def self.next_record(input : InputData, record : LibHTS::Bam1T*) : LibC::Int
        loop do
          rc = read_record(input, record)
          return rc if rc < 0
          next if input.filter.skip?(record)

          return 0
        end
      end

      private def self.read_record(input : InputData, record : LibHTS::Bam1T*) : LibC::Int
        if input.itr.null?
          LibHTS.sam_read1(input.htsfp, input.hdr, record)
        else
          LibHTS2.sam_itr_next(input.htsfp, input.itr, record)
        end
      end

      private def build_iterator(bam : Bam, region : String?, regions : Array(String)?) : LibHTS::HtsItrT*
        return Pointer(LibHTS::HtsItrT).null if region.nil? && regions.nil?

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
