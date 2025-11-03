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
      @cb : LibHTS::BamPlpAutoF?   # keepalive for C callback
      @udata : Pointer(InputData)? # keepalive of user data for callback
      @maxcnt : Int32?

      # region is optional for future extension. For now, full-stream iteration.
      def initialize(@bam : Bam, region : String? = nil, @maxcnt : Int32? = nil)
        # Prepare callback user data block
        @hdr = @bam.header
        @udata = Pointer(InputData).malloc(1)
        @udata.not_nil!.value = InputData.new(
          @bam.to_unsafe,
          @hdr.to_unsafe,
          Pointer(LibHTS::HtsItrT).null
        )

        # Read function compatible with bam_plp_init
        @cb = ->(data : Void*, b : LibHTS::Bam1T*) : LibC::Int {
          id = data.as(Pointer(InputData)).value
          if id.itr.null?
            # Whole-file path
            r = LibHTS.sam_read1(id.htsfp, id.hdr, b)
            r >= 0 ? 0 : -1
          else
            # Region iterator path (reserved for future use)
            r = LibHTS2.sam_itr_next(id.htsfp, id.itr, b)
            r >= 0 ? 0 : -1
          end
        }

        # Create iterator
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
            break if n >= 0
            raise "HTSlib pileup error (bam_plp64_auto)"
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
        # NOTE:
        # - @udata is allocated via Pointer.malloc (GC 管理) のため明示的に free しない。
        # - @cb は C コールバックの keepalive 用参照。オブジェクト存続中は保持される。
      end

      def finalize
        close
      end
    end
  end
end
