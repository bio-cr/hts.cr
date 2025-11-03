module HTS
  class Bam < Hts
    # High-level pileup iterator over a single BAM/CRAM input.
    # Yields Column objects with tid, pos, and alignments at each position.
    class Pileup
      # Represents a pileup column at a genomic position
      struct Column
        getter tid : Int32
        getter pos : Int64
        getter alignments : Array(Alignment)

        def initialize(@tid : Int32, @pos : Int64, @alignments : Array(Alignment)); end

        # Depth equals number of alignments covering this position
        def depth : Int32
          @alignments.size
        end
      end

      include Enumerable(Column)

      # C-callback user data. Packed pointers needed by the read function.
      struct InputData
        getter htsfp : LibHTS::HtsFile*
        getter hdr : LibHTS::SamHdrT*
        getter itr : LibHTS::HtsItrT*

        def initialize(@htsfp : LibHTS::HtsFile*, @hdr : LibHTS::SamHdrT*, @itr : LibHTS::HtsItrT*)
        end
      end

      # Thin wrapper around a single bam_pileup1_t entry
      class Alignment
        @entry : Pointer(LibHTS::BamPileup1T)
        @header : Bam::Header
        @record : Bam::Record?

        def initialize(@entry : Pointer(LibHTS::BamPileup1T), @header : Bam::Header)
        end

        # 0-based query position
        def query_pos : Int32
          @entry.value.qpos
        end

        # Indel length (0 no indel, >0 insertion, <0 deletion)
        def indel : Int32
          @entry.value.indel
        end

        # Bitfield helpers
        def del? : Bool
          (@entry.value.bitfields & 0x1) != 0
        end

        def head? : Bool
          (@entry.value.bitfields & 0x2) != 0
        end

        def tail? : Bool
          (@entry.value.bitfields & 0x4) != 0
        end

        def refskip? : Bool
          (@entry.value.bitfields & 0x8) != 0
        end

        # Lazily duplicates the underlying bam1_t to return a safe Record
        def record : Bam::Record
          if rec = @record
            return rec
          end
          b = @entry.value.b
          raise "null bam1_t" if b.null?
          dup = LibHTS.bam_dup1(b)
          raise "bam_dup1 failed" if dup.null?
          @record = Bam::Record.new(@header, dup)
        end
      end

      @bam : Bam
      @hdr : Bam::Header
      @plp : LibHTS::BamPlpT?
      @cb : LibHTS::BamPlpAutoF?    # keepalive for C callback
      @udata : Pointer(InputData)?  # keepalive of user data for callback
      @itr : LibHTS::HtsItrT*?      # keepalive for region iterator
      @idx_local : LibHTS::HtsIdxT? # optional index we loaded for region
      @maxcnt : Int32?

      # Create a Pileup iterator
      # @param bam [HTS::Bam]
      # @param region [String, nil] Optional region string (e.g., "chr1:1000-2000", requires index)
      # @param maxcnt [Int32, nil] Max per-position depth (capped)
      def initialize(@bam : Bam, region : String? = nil, @maxcnt : Int32? = nil)
        @hdr = @bam.header

        # Build region iterator if specified
        itr_ptr = Pointer(LibHTS::HtsItrT).null
        if region
          # Ensure we have an index; if not accessible, load a temporary one
          raise "Index file is required to use region pileup" unless @bam.index_loaded?

          # Load an index handle we can pass to htslib; keep it to destroy later
          idx_ptr = @bam.load_index
          raise "Index not available" if idx_ptr.null?
          @idx_local = idx_ptr

          # Create iterator from region string (1-based inclusive SAM-style)
          itr_ptr = LibHTS.sam_itr_querys(idx_ptr, @hdr.to_unsafe, region)
          raise "Failed to query region: #{region}" if itr_ptr.null?
          @itr = itr_ptr
        end

        # Prepare callback user data block
        @udata = Pointer(InputData).malloc(1)
        @udata.not_nil!.value = InputData.new(
          @bam.to_unsafe,
          @hdr.to_unsafe,
          itr_ptr
        )

        # Read function compatible with bam_plp_init
        # Expected return values:
        #   0 on success, -1 on EOF, < -1 on non-recoverable errors
        @cb = ->(data : Void*, b : LibHTS::Bam1T*) : LibC::Int {
          id = data.as(Pointer(InputData)).value
          if id.itr.null?
            # Whole-file path: sam_read1 returns -1 on EOF or error (no finer error code)
            r = LibHTS.sam_read1(id.htsfp, id.hdr, b)
            r >= 0 ? 0 : -1
          else
            # Region iterator path: sam_itr_next returns < -1 on error, -1 on EOF
            r = LibHTS2.sam_itr_next(id.htsfp, id.itr, b)
            r >= 0 ? 0 : r
          end
        }

        # Create pileup iterator
        @plp = LibHTS.bam_plp_init(@cb.not_nil!, @udata.not_nil!.as(Void*))
        raise "bam_plp_init failed" if @plp.nil? || @plp.not_nil!.as(Void*).null?
        if cnt = @maxcnt
          LibHTS.bam_plp_set_maxcnt(@plp.not_nil!, cnt)
        end
      end

      # Iterate over pileup columns
      def each(&block : Column ->) : Nil
        return unless (plp = @plp)

        tid = 0
        pos = 0_i64
        n = 0
        while true
          plp1 = LibHTS.bam_plp64_auto(plp, pointerof(tid), pointerof(pos), pointerof(n))
          if plp1.null?
            # bam_plp64_auto sets n = 0 on EOF, n < 0 on error
            break if n >= 0
            raise "HTSlib pileup error (bam_plp64_auto), n=#{n}"
          end

          aligns = Array(Alignment).new(n)
          i = 0
          while i < n
            entry_ptr = plp1 + i
            aligns << Alignment.new(entry_ptr, @hdr)
            i += 1
          end
          yield Column.new(tid, pos, aligns)
        end
      end

      # Reset internal state, if needed by the caller
      def reset : Nil
        LibHTS.bam_plp_reset(@plp) if @plp
      end

      # Release native resources
      def close : Nil
        if plp = @plp
          LibHTS.bam_plp_destroy(plp)
          @plp = nil
        end
        if itr = @itr
          LibHTS.hts_itr_destroy(itr)
          @itr = nil
        end
        if idx = @idx_local
          LibHTS.hts_idx_destroy(idx)
          @idx_local = nil
        end
        # NOTE:
        # - @udata is allocated via Pointer.malloc (GC managed), no explicit free needed.
        # - @cb is a keepalive reference for the C callback during iteration.
      end

      def finalize
        close
      end
    end
  end
end
