require "./flag"
require "./cigar"

module HTS
  class Bam < Hts
    class Record
      SEQ_NT16_STR = "=ACMGRSVTWYHKDBN"

      def initialize(bam1_t : Pointer(HTS::LibHTS::Bam1T), header : Bam::Header)
        @bam1 = bam1_t
        @header = header
      end

      def to_unsafe
        @bam1
      end

      getter :header

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

        String.new LibHTS.sam_hdr_tid2name(@header, tid)
      end

      # returns the mate chromosome or '' if not mapped.
      def contig
        chrom
      end

      # returns the chromosome of the mate or '' if not mapped.
      def mate_chrom
        return "" if mtid == -1

        String.new LibHTS.sam_hdr_tid2name(@header, mtid)
      end

      def mate_contig
        mate_chrom
      end

      def strand
        LibHTS2.bam_is_rev(@bam1) ? "-" : "+"
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
          (self.len).times do |i|
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
        n += self.len if n < 0
        return '.' if (n >= self.len) || (n < 0) # eg. base(-1000)

        r = LibHTS2.bam_get_seq(@bam1)
        SEQ_NT16_STR[LibHTS2.bam_seqi(r, n)]
      end

      # return the base qualities
      def qual
        q_ptr = LibHTS2.bam_get_qual(@bam1)
        Array.new(self.len) do |i|
          q_ptr[i]
        end
      end

      def qual_string
        q_ptr = LibHTS2.bam_get_qual(@bam1)
        lqseq = self.len
        str = String.new(lqseq) do |buffer|
          lqseq.times do |i|
            buffer[i] = q_ptr[i] + 33
          end
          {lqseq, 2}
        end
        str
      end

      # return only the base quality of the requested index "i" of the query sequence.
      def base_qual(n)
        n += self.len if n < 0
        return 0 if (n >= self.len) || (n < 0) # eg. base_qual(-1000)

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
        b = str.bytes
        str2 = StaticArray(UInt8, 2).new { |i| b[i] }
        LibHTS.bam_aux_get(@bam1, str2)
      end

      def aux(str)
        ax = get_aux_pointer(str)
        return nil if ax.null?

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

      # Retrun Int64
      def aux_int(str)
        ax = get_aux_pointer(str)
        LibHTS.bam_aux2i(ax)
      end

      def aux_float(str)
        ax = get_aux_pointer(str)
        LibHTS.bam_aux2f(ax)
      end

      def aux_string(str)
        ax = get_aux_pointer(str)
        String.new LibHTS.bam_aux2_z(ax)
      end

      def aux_char(str)
        ax = get_aux_pointer(str)
        LibHTS.bam_aux2_a(ax).chr
      end

      {% for name, _ in Flag::TABLE %}
      def {{ name.id }}
        flag.{{ name.id }}
      end
      {% end %}

      def to_s(io : IO)
        kstr = Pointer(LibHTS::KstringT).malloc
        raise "Failed to format bam record" if LibHTS.sam_format1(@header, @bam1, kstr) == -1

        io << (String.new kstr.value.s)
      end

      def clone
        # Duplicate bam1 and use references for header.
        bam1 = LibHTS.bam_dup1(@bam1)
        self.class.new(bam1, @header)
      end

      # garbagew collection
      def finalize
        LibHTS.bam_destroy1 @bam1 unless @bam1.null?
      end
    end
  end
end
