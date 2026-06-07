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
        raise "Failed to build record via bam_set1" if r < 0
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
        raise "Unknown reference name: #{rname}" if tid < 0
        initialize(header, qname, flag, tid, pos, mapq, Cigar.encode(cigar_str), seq, qual, mtid, mpos, isize)
      end

      private def new_bam1! : LibHTS::Bam1T*
        bam1 = LibHTS.bam_init1
        raise "bam_init1 failed" if bam1.null?
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

      # returns a `Cigar` object.
      def cigar
        Cigar.new(LibHTS2.bam_get_cigar(@bam1), @bam1.value.core.n_cigar)
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

      # return the read sequence
      def seq
        r = LibHTS2.bam_get_seq(@bam1)
        String.build do |seq|
          (len).times do |i|
            seq << SEQ_NT16_STR[LibHTS2.bam_seqi(r, i)]
          end
        end
      end

      def sequence
        seq
      end

      def len
        @bam1.value.core.l_qseq
      end

      # return only the base of the requested index "i" of the query sequence.
      def base(n)
        n += len if n < 0
        return '.' if (n >= len) || (n < 0) # eg. base(-1000)

        r = LibHTS2.bam_get_seq(@bam1)
        SEQ_NT16_STR[LibHTS2.bam_seqi(r, n)]
      end

      # return the base qualities
      def qual
        q_ptr = LibHTS2.bam_get_qual(@bam1)
        Array.new(len) do |i|
          q_ptr[i]
        end
      end

      def qual_string
        q_ptr = LibHTS2.bam_get_qual(@bam1)
        return "" if len == 0
        return "*" if len.times.all? { |i| q_ptr[i] == 0xff }
        raise ArgumentError.new("missing base quality cannot be represented in QUAL string") if len.times.any? { |i| q_ptr[i] == 0xff }

        slice = Slice.new(len) { |i| (q_ptr[i].to_i + 33).to_u8 }
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

      def flag=(flag)
        @bam1.value.core.flag = flag
      end

      def flag=(flag : Flag)
        @bam1.value.core.flag = flag.value
      end

      private def get_aux_pointer(str)
        str2 = Bam.aux_tag_to_static_array(str)
        LibHTS.bam_aux_get(@bam1, str2)
      end

      # Access individual auxiliary tag by name (existing method)
      def aux(str)
        ax = get_aux_pointer(str)
        return if ax.null?

        # A (character), B (general array),
        # f (real number), H (hexadecimal array),
        # i (integer), or Z (string).

        t = ax.value
        case t
        when 'i', 'I', 'c', 'C', 's', 'S'
          LibHTS.bam_aux2i(ax)
        when 'f', 'd'
          LibHTS.bam_aux2f(ax)
        when 'Z', 'H'
          String.new LibHTS.bam_aux2_z(ax)
        when 'A'
          LibHTS.bam_aux2_a(ax).chr
        end
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

      {% for name, _ in Flag::TABLE %}
      def {{ name.id }}
        flag.{{ name.id }}
      end
      {% end %}

      def to_s(io : IO)
        kstr = LibHTS::KstringT.new
        kstr.l = 0
        kstr.m = 0
        kstr.s = Pointer(LibC::Char).null

        begin
          raise "Failed to format bam record" if LibHTS.sam_format1(@header, @bam1, pointerof(kstr)) == -1

          io << (String.new kstr.s)
        ensure
          LibC.free(kstr.s) unless kstr.s.null?
        end
      end

      def clone
        # Duplicate bam1 and use references for header.
        bam1 = LibHTS.bam_dup1(@bam1)
        raise "bam_dup1 failed" if bam1.null?

        self.class.new(@header, bam1)
      end

      # Base modification accessor
      # NOTE: Currently always returns a new BaseMod instance to avoid a finalizer cycle
      #       between Record and BaseMod. In the future, memoization could be considered
      #       for performance optimization once the GC cycle issue is resolved.
      def base_mod : Bam::BaseMod
        Bam::BaseMod.new(self)
      end

      # garbagew collection
      def finalize
        LibHTS.bam_destroy1 @bam1 unless @bam1.null?
      end
    end
  end
end
