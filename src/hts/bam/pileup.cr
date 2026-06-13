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
        @header : Bam::Header

        def initialize(@tid : Int32, @pos : Int64, @alignments : Array(Alignment), @header : Bam::Header); end

        # Depth equals number of alignments covering this position
        def depth : Int32
          @alignments.size
        end

        # Reference (chromosome) name for this position
        # Returns empty string if tid is -1 (unmapped)
        def chrom : String
          return "" if @tid == -1
          @header.target_name(@tid)
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

      # Thin wrapper around a single bam_pileup1_t entry.
      # Small fields are copied so they remain valid after the iterator moves on.
      class Alignment
        @entry : Pointer(LibHTS::BamPileup1T)
        @header : Bam::Header
        @record : Bam::Record?
        @qname : String?
        getter query_pos : Int32
        getter indel : Int32
        getter bitfields : UInt32
        getter base : Char?
        getter base_qual : UInt8?

        def initialize(@entry : Pointer(LibHTS::BamPileup1T), @header : Bam::Header)
          @query_pos = @entry.value.qpos
          @indel = @entry.value.indel
          @bitfields = @entry.value.bitfields
          @base = nil
          @base_qual = nil

          unless del? || refskip?
            b = bam1
            unless b.null?
              if @query_pos >= 0 && @query_pos < b.value.core.l_qseq
                seq = LibHTS2.bam_get_seq(b)
                qual = LibHTS2.bam_get_qual(b)
                @base = Bam::Record::SEQ_NT16_STR[LibHTS2.bam_seqi(seq, @query_pos)]
                @base_qual = qual[@query_pos]
              end
            end
          end
        end

        # Bitfield helpers
        def del? : Bool
          (@bitfields & 0x1) != 0
        end

        def head? : Bool
          (@bitfields & 0x2) != 0
        end

        def tail? : Bool
          (@bitfields & 0x4) != 0
        end

        def refskip? : Bool
          (@bitfields & 0x8) != 0
        end

        # Query name for the underlying read without duplicating the full record.
        # Call this before the pileup iterator advances or closes.
        def qname : String
          if name = @qname
            return name
          end
          b = bam1
          raise "null bam1_t" if b.null?
          @qname = String.new(LibHTS2.bam_get_qname(b))
        end

        # Lazily duplicates the underlying bam1_t. This is convenient but
        # relatively expensive in pileup hot paths; prefer direct accessors such
        # as `base`, `base_qual`, and `qname` when possible.
        # Call this before the pileup iterator advances or closes.
        def record : Bam::Record
          if rec = @record
            return rec
          end
          b = bam1
          raise "null bam1_t" if b.null?
          dup = LibHTS.bam_dup1(b)
          raise "bam_dup1 failed" if dup.null?
          @record = Bam::Record.new(@header, dup)
        end

        private def bam1 : LibHTS::Bam1T*
          @entry.value.b
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

      # Open a Pileup iterator with block (RAII style)
      def self.open(bam : Bam, region : String? = nil, maxcnt : Int32? = nil, &)
        pileup = new(bam, region, maxcnt)
        begin
          yield pileup
        ensure
          pileup.close
        end
      end

      # Open a Pileup iterator using keyword arguments, matching Mpileup.
      def self.open(bam : Bam, *, region : String? = nil, maxcnt : Int32? = nil, &)
        open(bam, region, maxcnt) { |pileup| yield pileup }
      end

      # Create a Pileup iterator
      # @param bam [HTS::Bam]
      # @param region [String, nil] Optional region string (e.g., "chr1:1000-2000", requires index)
      # @param maxcnt [Int32, nil] Max per-position depth (capped)
      def initialize(@bam : Bam, region : String? = nil, @maxcnt : Int32? = nil)
        @hdr = uninitialized Bam::Header

        begin
          @hdr = @bam.header

          itr_ptr = init_region_iterator(region)

          udata = Pointer(InputData).malloc(1)
          @udata = udata
          udata.value = InputData.new(
            @bam.to_unsafe,
            @hdr.to_unsafe,
            itr_ptr
          )

          cb = pileup_read_callback
          @cb = cb

          plp = LibHTS.bam_plp_init(cb, udata.as(Void*))
          raise "bam_plp_init failed" if plp.nil? || plp.as(Void*).null?
          @plp = plp
          if cnt = @maxcnt
            LibHTS.bam_plp_set_maxcnt(plp, cnt)
          end
        rescue ex
          close rescue nil
          raise ex
        end
      end

      # Iterate over pileup columns
      def each(& : Column ->) : Nil
        return unless plp = @plp

        tid = 0
        pos = 0_i64
        n = 0
        loop do
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
          yield Column.new(tid, pos, aligns, @hdr)
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

      private def init_region_iterator(region : String?) : LibHTS::HtsItrT*
        itr_ptr = Pointer(LibHTS::HtsItrT).null
        return itr_ptr unless region

        raise "Index file is required to use region pileup" unless @bam.index_loaded?

        idx_ptr = @bam.load_index
        raise "Index not available" if idx_ptr.null?
        @idx_local = idx_ptr

        itr_ptr = LibHTS.sam_itr_querys(idx_ptr, @hdr.to_unsafe, region)
        raise "Failed to query region: #{region}" if itr_ptr.null?
        @itr = itr_ptr
        itr_ptr
      end

      private def pileup_read_callback
        ->(data : Void*, b : LibHTS::Bam1T*) : LibC::Int {
          id = data.as(Pointer(InputData)).value
          if id.itr.null?
            r = LibHTS.sam_read1(id.htsfp, id.hdr, b)
            r >= 0 ? 0 : -1
          else
            r = LibHTS2.sam_itr_next(id.htsfp, id.itr, b)
            r >= 0 ? 0 : r
          end
        }
      end
    end
  end
end
