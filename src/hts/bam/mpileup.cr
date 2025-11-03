module HTS
  class Bam < Hts
    # High-level mpileup iterator over multiple BAM/CRAM inputs.
    # Yields an Array of Pileup::Column (one per input) for each position.
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
      @owned_bams : Array(Bam) = [] of Bam
      @iter : LibHTS::BamMplpT?
      @cb : LibHTS::BamPlpAutoF? # keepalive
      @data_blocks : Array(Pointer(InputData)) = [] of Pointer(InputData)
      @data_array : Pointer(Pointer(Void))? # pointer to array of per-input data pointers
      @n_inputs : Int32
      @maxcnt : Int32?
      @overlaps : Bool

      # Open an Mpileup iterator with block (RAII style)
      def self.open(inputs : Array(Bam), maxcnt : Int32? = nil, overlaps : Bool = false, &)
        mpileup = new(inputs, maxcnt, overlaps)
        begin
          yield mpileup
        ensure
          mpileup.close
        end
      end

      # Minimal constructor: accept Array(Bam). (String inputs or regions can be added later.)
      def initialize(inputs : Array(Bam), @maxcnt : Int32? = nil, overlaps : Bool = false)
        @bams = inputs
        @n_inputs = inputs.size
        @overlaps = overlaps

        # Build per-input data blocks
        @data_blocks = Array(Pointer(InputData)).new(@n_inputs)
        @bams.each do |bam|
          block = Pointer(InputData).malloc(1)
          block.value = InputData.new(
            bam.to_unsafe,
            bam.header.to_unsafe,
            Pointer(LibHTS::HtsItrT).null
          )
          @data_blocks << block
        end

        # Make contiguous array of void* pointers to pass to bam_mplp_init
        @data_array = Pointer(Pointer(Void)).malloc(@n_inputs)
        i = 0
        while i < @n_inputs
          # Store as void*
          @data_array.not_nil![i] = @data_blocks[i].as(Void*)
          i += 1
        end

        # Shared callback used for all inputs
        @cb = ->(data : Void*, b : LibHTS::Bam1T*) : LibC::Int {
          id = data.as(Pointer(InputData)).value
          if id.itr.null?
            r = LibHTS.sam_read1(id.htsfp, id.hdr, b)
            r >= 0 ? 0 : -1
          else
            r = LibHTS2.sam_itr_next(id.htsfp, id.itr, b)
            r >= 0 ? 0 : -1
          end
        }

        @iter = LibHTS.bam_mplp_init(@n_inputs, @cb.not_nil!, @data_array.not_nil!.as(Void**))
        raise "bam_mplp_init failed" if @iter.nil? || @iter.not_nil!.as(Void*).null?

        if cnt = @maxcnt
          LibHTS.bam_mplp_set_maxcnt(@iter.not_nil!, cnt)
        end
        if @overlaps
          rc = LibHTS.bam_mplp_init_overlaps(@iter.not_nil!)
          raise "bam_mplp_init_overlaps failed" if rc < 0
        end
      end

      # Iterate and yield per-position columns array (aligned by tid,pos across inputs)
      def each(&block : Array(HTS::Bam::Pileup::Column) ->) : Nil
        return unless (iter = @iter)

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
              cols << HTS::Bam::Pileup::Column.new(tid, pos, [] of HTS::Bam::Pileup::Alignment)
            else
              aligns = Array(HTS::Bam::Pileup::Alignment).new(count)
              i = 0
              while i < count
                aligns << HTS::Bam::Pileup::Alignment.new(base_ptr + i, @bams[s].header)
                i += 1
              end
              cols << HTS::Bam::Pileup::Column.new(tid, pos, aligns)
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
        # Note: @data_blocks and @data_array are GC-managed (via Pointer.malloc)
        # and will be automatically freed by the GC.
      end

      def finalize
        close
      end
    end
  end
end
