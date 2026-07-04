module HTS
  class Bam < Hts
    # High-level pileup iterator over a single BAM/CRAM input.
    # Yields a zero-copy Column view (tid, pos, and per-read Alignment access) at
    # each position. Iterating a Column allocates nothing per read; see Column's
    # borrowing contract for the validity rules.
    class Pileup
      # Read-level filter applied by the pileup engine before a record reaches a
      # column. Shared by both Pileup (single input) and Mpileup (multiple inputs).
      #
      # Flags follow the SAM/samtools convention (see Bam::Flag constants):
      #   exclude_flags - skip the read if ANY of these bits are set   (samtools -F / --ff)
      #   require_flags - skip the read unless ALL of these bits are set (samtools -f)
      #   min_mapq      - skip reads with mapping quality below this
      #   count_orphans - when false, skip paired reads not in a proper pair
      #
      # Example:
      #   Pileup::Filter.new(min_mapq: 20,
      #     exclude_flags: Bam::Flag::UNMAP | Bam::Flag::SECONDARY |
      #                    Bam::Flag::QCFAIL | Bam::Flag::DUP | Bam::Flag::SUPPLEMENTARY,
      #     count_orphans: false)
      struct Filter
        getter min_mapq : Int32
        getter? count_orphans : Bool
        @exclude_flags : UInt16
        @require_flags : UInt16

        def initialize(@min_mapq : Int32 = 0, *,
                       exclude_flags : Bam::Flag = Bam::Flag::NONE,
                       require_flags : Bam::Flag = Bam::Flag::NONE,
                       count_orphans : Bool = true)
          raise ArgumentError.new("min_mapq must be non-negative") if @min_mapq < 0
          @exclude_flags = exclude_flags.to_i
          @require_flags = require_flags.to_i
          @count_orphans = count_orphans
        end

        def exclude_flags : Bam::Flag
          Bam::Flag.new(@exclude_flags)
        end

        def require_flags : Bam::Flag
          Bam::Flag.new(@require_flags)
        end

        # Whether the pileup engine should skip this record.
        def skip?(rec : LibHTS::Bam1T*) : Bool
          flag = rec.value.core.flag
          return true if @exclude_flags != 0 && (flag & @exclude_flags) != 0
          return true if @require_flags != 0 && (flag & @require_flags) != @require_flags
          return true if rec.value.core.qual.to_i < @min_mapq
          unless count_orphans?
            return true if (flag & LibHTS2::BAM_FPAIRED) != 0 && (flag & LibHTS2::BAM_FPROPER_PAIR) == 0
          end
          false
        end
      end

      # Thin value-type view over a single bam_pileup1_t entry. Small scalars
      # (query_pos, indel, bitfields, base, base_qual) are copied at construction
      # so they remain valid after the iterator moves on; record()/qname() reach
      # back into the live htslib record and must be called during iteration.
      # qname()/record() memoization is per captured Alignment value; repeated
      # `column[0].record` calls construct fresh Alignment values and duplicate
      # the record each time. Store `alignment = column[0]` when reusing them.
      # A struct so that iterating a Column allocates no per-read heap object.
      struct Alignment
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
          raise PileupError.new("null bam1_t") if b.null?
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
          raise PileupError.new("null bam1_t") if b.null?
          dup = LibHTS.bam_dup1(b)
          raise PileupError.new("bam_dup1 failed") if dup.null?
          @record = Bam::Record.new(@header, dup)
        end

        private def bam1 : LibHTS::Bam1T*
          @entry.value.b
        end
      end

      # A pileup column at a genomic position, as a zero-copy view over htslib's
      # current pileup buffer. It holds only pointers and constructs Alignment
      # values lazily, so iterating (#each / #[]) allocates nothing per read and
      # matches the C mpileup hot-path cost.
      #
      # BORROWING CONTRACT: a Column and any Alignment obtained from it are valid
      # ONLY during the current iteration step (the current block invocation).
      # To retain data across positions, read the copied-out scalars
      # (Alignment#base, #base_qual, #query_pos) or call Alignment#record. Do not
      # deref a Column after the iterator advances or the Pileup is closed.
      #
      # This borrowed view intentionally does not include Enumerable: methods
      # such as `to_a` or `map` would make short-lived C-backed entries look
      # like ordinary retained Crystal values.
      struct Column
        getter tid : Int32
        getter pos : Int64
        @base : Pointer(LibHTS::BamPileup1T)
        @count : Int32
        @header : Bam::Header

        def initialize(@tid : Int32, @pos : Int64, @base : Pointer(LibHTS::BamPileup1T),
                       @count : Int32, @header : Bam::Header)
        end

        # Depth equals number of alignments covering this position
        def depth : Int32
          @count
        end

        # Number of reads covering this position.
        def count : Int32
          @count
        end

        # Count reads matching the block without materializing an Array.
        def count(& : Alignment -> Bool) : Int32
          matched = 0
          each do |alignment|
            matched += 1 if yield alignment
          end
          matched
        end

        # Reference (chromosome) name for this position
        # Returns empty string if tid is -1 (unmapped)
        def chrom : String
          return "" if @tid == -1
          @header.target_name(@tid)
        end

        # Iterate the reads covering this position without allocating an Array.
        def each(& : Alignment ->) : Nil
          return if @count <= 0 || @base.null?
          i = 0
          while i < @count
            yield Alignment.new(@base + i, @header)
            i += 1
          end
        end

        def [](index : Int32) : Alignment
          raise IndexError.new("pileup column index #{index} out of range 0...#{@count}") unless 0 <= index < @count
          Alignment.new(@base + index, @header)
        end
      end

      # C-callback user data. Packed pointers needed by the read function.
      struct InputData
        getter htsfp : LibHTS::HtsFile*
        getter hdr : LibHTS::SamHdrT*
        getter itr : LibHTS::HtsItrT*
        getter filter : Filter

        def initialize(@htsfp : LibHTS::HtsFile*, @hdr : LibHTS::SamHdrT*, @itr : LibHTS::HtsItrT*, @filter : Filter)
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
      def self.open(bam : Bam, region : String? = nil, maxcnt : Int32? = nil, *, filter : Filter = Filter.new, &)
        pileup = new(bam, region, maxcnt, filter: filter)
        begin
          yield pileup
        ensure
          pileup.close
        end
      end

      # Open a Pileup iterator using keyword arguments, matching Mpileup.
      def self.open(bam : Bam, *, region : String? = nil, maxcnt : Int32? = nil, filter : Filter = Filter.new, &)
        open(bam, region, maxcnt, filter: filter) { |pileup| yield pileup }
      end

      # Create a Pileup iterator
      # @param bam [HTS::Bam]
      # @param region [String, nil] Optional region string (e.g., "chr1:1000-2000", requires index)
      # @param maxcnt [Int32, nil] Max per-position depth (capped)
      # @param filter [Filter] Read-level filter applied before pileup (see Filter)
      def initialize(@bam : Bam, region : String? = nil, @maxcnt : Int32? = nil, *, filter : Filter = Filter.new)
        @hdr = uninitialized Bam::Header

        begin
          @hdr = @bam.header

          itr_ptr =
            if region_string = region
              init_region_iterator(region_string)
            else
              Pointer(LibHTS::HtsItrT).null
            end

          udata = Pointer(InputData).malloc(1)
          @udata = udata
          udata.value = InputData.new(
            @bam.to_unsafe,
            @hdr.to_unsafe,
            itr_ptr,
            filter
          )

          cb = pileup_read_callback
          @cb = cb

          plp = LibHTS.bam_plp_init(cb, udata.as(Void*))
          raise PileupError.new("bam_plp_init failed") if plp.nil? || plp.as(Void*).null?
          @plp = plp
          if cnt = @maxcnt
            LibHTS.bam_plp_set_maxcnt(plp, cnt)
          end
        rescue ex
          close rescue nil
          raise ex
        end
      end

      # Iterate over pileup columns. Yields a zero-copy Column view valid only
      # for the duration of the block (see Column's borrowing contract).
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
            raise PileupError.new("HTSlib pileup error (bam_plp64_auto), n=#{n}")
          end

          yield Column.new(tid, pos, plp1, n, @hdr)
        end
      end

      # Count pileup columns by consuming this iterator.
      def count : Int32
        total = 0
        each { total += 1 }
        total
      end

      # Count pileup columns matching the block by consuming this iterator.
      def count(& : Column -> Bool) : Int32
        matched = 0
        each do |column|
          matched += 1 if yield column
        end
        matched
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

      private def init_region_iterator(region : String) : LibHTS::HtsItrT*
        raise MissingIndexError.new("Index file is required to use region pileup") unless @bam.index_loaded?

        idx_ptr = @bam.load_index
        raise MissingIndexError.new("Index not available") if idx_ptr.null?
        @idx_local = idx_ptr

        itr_ptr = LibHTS.sam_itr_querys(idx_ptr, @hdr.to_unsafe, region)
        raise QueryError.new("Failed to query region: #{region}") if itr_ptr.null?
        @itr = itr_ptr
        itr_ptr
      end

      private def pileup_read_callback
        ->(data : Void*, b : LibHTS::Bam1T*) : LibC::Int {
          id = data.as(Pointer(InputData)).value
          loop do
            r = if id.itr.null?
                  LibHTS.sam_read1(id.htsfp, id.hdr, b)
                else
                  LibHTS2.sam_itr_next(id.htsfp, id.itr, b)
                end
            return r if r < 0
            next if id.filter.skip?(b)
            return 0
          end
        }
      end
    end
  end
end
