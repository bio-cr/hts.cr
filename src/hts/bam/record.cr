require "./flag"
require "./cigar"
require "./auxi"

module HTS
  class Bam < Hts
    class Record
      SEQ_NT16_STR = "=ACMGRSVTWYHKDBN"

      def initialize(header : Bam::Header, bam1_t : Pointer(HTS::LibHTS::Bam1T))
        @header = header
        @bam1 = bam1_t
      end

      def initialize(header : Bam::Header)
        @header = header
        @bam1 = new_bam1!
      end

      def to_unsafe
        @bam1
      end

      getter :header

      # Convenience constructor: build a record with core fields using bam_set1
      # - Coordinates are 0-based (as in BAM core)
      # - CIGAR may be given as encoded words (Array(UInt32)) or SAM string
      # - Qualities are Phred-scaled values (0..93), one per base
      def initialize(header : Bam::Header,
                     qname : String,
                     flag : UInt16 | Int32,
                     tid : Int32,
                     pos : Int64,
                     mapq : UInt8 | Int32,
                     cigar_words : Array(UInt32),
                     seq : String,
                     qual : Array(UInt8),
                     mtid : Int32 = -1,
                     mpos : Int64 = 0_i64,
                     isize : Int64 = 0_i64)
        @header = header
        @bam1 = new_bam1!

        raise ArgumentError.new("qual length must equal sequence length") unless qual.size == seq.bytesize

        r = LibHTS.bam_set1(
          @bam1,
          qname.bytesize, qname,
          flag.to_u16,
          tid, pos,
          mapq.to_u8,
          cigar_words.size, cigar_words.to_unsafe,
          mtid, mpos, isize,
          seq.bytesize, seq,
          qual,
          0
        )
        raise RecordError.new("Failed to build record via bam_set1") if r < 0
      end

      # Overload: rname + CIGAR as String
      def initialize(header : Bam::Header,
                     qname : String,
                     flag : UInt16 | Int32,
                     rname : String,
                     pos : Int64,
                     mapq : UInt8 | Int32,
                     cigar_str : String,
                     seq : String,
                     qual : Array(UInt8),
                     mtid : Int32 = -1,
                     mpos : Int64 = 0_i64,
                     isize : Int64 = 0_i64)
        tid = header.get_tid(rname)
        raise ArgumentError.new("Unknown reference name: #{rname}") if tid < 0
        initialize(header, qname, flag, tid, pos, mapq, Cigar.encode(cigar_str), seq, qual, mtid, mpos, isize)
      end

      private def new_bam1! : LibHTS::Bam1T*
        bam1 = LibHTS.bam_init1
        raise RecordError.new("bam_init1 failed") if bam1.null?
        bam1
      end

      # returns the query name.
      def qname
        String.new LibHTS2.bam_get_qname(@bam1)
      end

      def qname=(name)
        LibHTS.bam_set_qname(@bam1, name)
      end

      # returns the tid of the record or -1 if not mapped.
      def tid
        @bam1.value.core.tid
      end

      def tid=(tid)
        @bam1.value.core.tid = tid
      end

      # returns the tid of the mate or -1 if not mapped.
      def mtid
        @bam1.value.core.mtid
      end

      def mtid=(mtid)
        @bam1.value.core.mtid = mtid
      end

      # returns 0-based start position.
      def pos
        @bam1.value.core.pos
      end

      def pos=(pos)
        @bam1.value.core.pos = pos
      end

      # returns 0-based mate position
      def mate_pos
        @bam1.value.core.mpos
      end

      def mate_pos=(mpos)
        @bam1.value.core.mpos = mpos
      end

      def mpos
        mate_pos
      end

      def mpos=(mpos)
        self.mate_pos = mpos
      end

      def bin
        @bam1.value.core.bin
      end

      def bin=(bin)
        @bam1.value.core.bin = bin
      end

      # returns end position of the read.
      def endpos
        LibHTS.bam_endpos @bam1
      end

      # returns the chromosome or '' if not mapped.
      def chrom
        return "" if tid == -1

        name = LibHTS.sam_hdr_tid2name(@header, tid)
        return "" if name.null?

        String.new(name)
      end

      # returns the mate chromosome or '' if not mapped.
      def contig
        chrom
      end

      # returns the chromosome of the mate or '' if not mapped.
      def mate_chrom
        return "" if mtid == -1

        name = LibHTS.sam_hdr_tid2name(@header, mtid)
        return "" if name.null?

        String.new(name)
      end

      def mate_contig
        mate_chrom
      end

      def strand
        LibHTS2.bam_is_rev(@bam1) ? "-" : "+"
      end

      def mate_strand
        LibHTS2.bam_is_mrev(@bam1) ? "-" : "+"
      end

      # insert size
      def insert_size
        @bam1.value.core.isize
      end

      def insert_size=(isize)
        @bam1.value.core.isize = isize
      end

      def isize
        insert_size
      end

      def isize=(isize)
        self.insert_size = isize
      end

      # mapping quality
      def mapq
        @bam1.value.core.qual
      end

      def mapq=(mapq)
        @bam1.value.core.qual = mapq
      end

      # Returns an independent, allocating `Cigar` object.
      def cigar
        Cigar.new(LibHTS2.bam_get_cigar(@bam1), @bam1.value.core.n_cigar)
      end

      # Returns the number of CIGAR operations in this record without
      # allocating a `Cigar` object.
      def cigar_size : UInt32
        @bam1.value.core.n_cigar
      end

      # Returns one CIGAR operation without allocating a `Cigar` object.
      def cigar_at(index : Int) : Tuple(Char, UInt32)?
        index += cigar_size if index < 0
        return unless 0 <= index < cigar_size

        cigar_ptr = LibHTS2.bam_get_cigar(@bam1)
        raise RecordError.new("BAM record has CIGAR operations but no CIGAR data") if cigar_ptr.null?

        cigar_op = cigar_ptr[index]
        {LibHTS2.bam_cigar_opchr(cigar_op), LibHTS2.bam_cigar_oplen(cigar_op)}
      end

      # Iterate over CIGAR operations without allocating a `Cigar` object or
      # copying the encoded CIGAR words out of the BAM record. This yields the
      # same `{op, len}` tuple shape as `Cigar#each`, but reads from this record's
      # underlying BAM memory during the block. Use `#cigar` when an independent,
      # retained CIGAR object is needed.
      def each_cigar(& : Tuple(Char, UInt32) ->) : self
        return self if cigar_size == 0

        cigar_ptr = LibHTS2.bam_get_cigar(@bam1)
        raise RecordError.new("BAM record has CIGAR operations but no CIGAR data") if cigar_ptr.null?

        cigar_size.times do |i|
          cigar_op = cigar_ptr[i]
          yield({LibHTS2.bam_cigar_opchr(cigar_op), LibHTS2.bam_cigar_oplen(cigar_op)})
        end
        self
      end

      def qlen
        LibHTS.bam_cigar2qlen(
          @bam1.value.core.n_cigar,
          LibHTS2.bam_get_cigar(@bam1)
        )
      end

      def rlen
        LibHTS.bam_cigar2rlen(
          @bam1.value.core.n_cigar,
          LibHTS2.bam_get_cigar(@bam1)
        )
      end

      # Returns the read sequence as an allocating `String`.
      def seq
        String.build(len) do |seq|
          each_base { |base| seq << base }
        end
      end

      def sequence
        seq
      end

      def len
        @bam1.value.core.l_qseq
      end

      # The packed 4-bit sequence is borrowed from this record.
      @[Experimental]
      def packed_sequence_view : Bytes
        packed_size = (len + 1) // 2
        pointer = LibHTS2.bam_get_seq(@bam1)
        if packed_size > 0 && pointer.null?
          raise RecordError.new("BAM record has sequence length but no sequence data")
        end
        Slice.new(pointer, packed_size)
      end

      # return only the base of the requested index "i" of the query sequence.
      def base(n)
        n += len if n < 0
        return '.' if (n >= len) || (n < 0) # eg. base(-1000)

        r = LibHTS2.bam_get_seq(@bam1)
        SEQ_NT16_STR[LibHTS2.bam_seqi(r, n)]
      end

      # Streams query sequence bases without building a `String`.
      def each_base(& : Char ->) : self
        r = LibHTS2.bam_get_seq(@bam1)
        len.times do |i|
          yield SEQ_NT16_STR[LibHTS2.bam_seqi(r, i)]
        end
        self
      end

      # Returns base qualities as an allocating `Array`.
      def qual
        qualities = Array(UInt8).new(len)
        each_qual { |quality| qualities << quality }
        qualities
      end

      # Streams base qualities without building an `Array`.
      def each_qual(& : UInt8 ->) : self
        q_ptr = LibHTS2.bam_get_qual(@bam1)
        len.times do |i|
          yield q_ptr[i]
        end
        self
      end

      # Return base qualities as a Phred+33 QUAL string.
      #
      # Matches htslib's SAM formatter: if the first quality byte is 0xff,
      # QUAL is returned as "*"; otherwise each quality byte is emitted as
      # byte + 33 without validating later bytes.
      def qual_string
        q_ptr = LibHTS2.bam_get_qual(@bam1)
        return "" if len == 0
        return "*" if q_ptr[0] == 0xff

        slice = Slice.new(len) { |i| q_ptr[i] &+ 33_u8 }
        String.new(slice)
      end

      # return only the base quality of the requested index "i" of the query sequence.
      def base_qual(n)
        n += len if n < 0
        return 0 if (n >= len) || (n < 0) # eg. base_qual(-1000)

        q_ptr = LibHTS2.bam_get_qual(@bam1)
        q_ptr[n]
      end

      # returns a `Flag` object.
      def flag
        Flag.new @bam1.value.core.flag
      end

      def flag_value : UInt16
        @bam1.value.core.flag
      end

      def has_flag?(mask) : Bool
        (flag_value & mask.to_u16) != 0
      end

      def flag=(flag)
        @bam1.value.core.flag = flag
      end

      def flag=(flag : Flag)
        @bam1.value.core.flag = flag.value
      end

      # Return Aux object for iteration over all auxiliary tags
      def aux
        Aux.new(@bam1)
      end

      # Return Int64
      def aux_int(str) : Int64?
        aux.get_int(str)
      end

      def aux_float(str) : Float64?
        aux.get_float(str)
      end

      def aux_string(str) : String?
        aux.get_string(str)
      end

      def aux_char(str) : Char?
        aux.get_char(str)
      end

      {% for name, flag_mask in Flag::TABLE %}
      def {{ name.id }}
        has_flag?({{ flag_mask.id }})
      end
      {% end %}

      def to_s(io : IO)
        kstr = LibHTS::KstringT.new
        kstr.l = 0
        kstr.m = 0
        kstr.s = Pointer(LibC::Char).null

        begin
          raise RecordError.new("Failed to format BAM record") if LibHTS.sam_format1(@header, @bam1, pointerof(kstr)) == -1

          io << (String.new kstr.s)
        ensure
          LibC.free(kstr.s) unless kstr.s.null?
        end
      end

      def clone
        # Duplicate bam1 and use references for header.
        bam1 = LibHTS.bam_dup1(@bam1)
        raise RecordError.new("bam_dup1 failed") if bam1.null?

        self.class.new(@header, bam1)
      end

      # Base modification accessor
      # NOTE: Currently always returns a new BaseMod instance to avoid a finalizer cycle
      #       between Record and BaseMod. In the future, memoization could be considered
      #       for performance optimization once the GC cycle issue is resolved.
      def base_mod : Bam::BaseMod
        Bam::BaseMod.new(self)
      end

      # Streams primitive base-modification fields without domain objects.
      @[Experimental]
      def each_base_mod_raw(max_mods : Int32 = 10, & : Int32, Int32, Int32, Int32, Int32 ->) : self
        base_mod = Bam::BaseMod.new(self)
        begin
          base_mod.each_raw(max_mods) do |position, canonical_base, modified_base, strand, qual|
            yield position, canonical_base, modified_base, strand, qual
          end
        ensure
          base_mod.close
        end
        self
      end

      # garbagew collection
      def finalize
        LibHTS.bam_destroy1 @bam1 unless @bam1.null?
      end
    end
  end
end
