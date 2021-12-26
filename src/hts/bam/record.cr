module HTS
  class Bam
    class Record
      SEQ_NT16_STR = "=ACMGRSVTWYHKDBN"

      def initialize(bam1_t : Pointer(HTS::LibHTS::Bam1T), header : Header)
        @bam1 = bam1_t
        @header = header
      end

      def struct
        @bam1
      end

      getter :header

      # returns the query name.
      def qname
        String.new(LibHTS2.bam_get_qname(@bam1))
      end

      # Set (query) name.
      # def qname=(name)
      #   raise 'Not Implemented'
      # end

      # returns the tid of the record or -1 if not mapped.
      def tid
        @bam1.value.core.tid
      end

      # returns the tid of the mate or -1 if not mapped.
      def mate_tid
        @bam1.value.core.mtid
      end

      # returns 0-based start position.
      def start
        @bam1.value.core.pos
      end

      # returns end position of the read.
      def stop
        LibHTS.bam_endpos @bam1
      end

      # returns 0-based mate position
      def mate_start
        @bam1.value.core.mpos
      end

      def mate_pos
        mate_start
      end

      # returns the chromosome or '' if not mapped.
      def chrom
        typeof(@bam1)
        return "" if tid == -1

        String.new(LibHTS.sam_hdr_tid2name(@header.struct, tid))
      end

      # returns the chromosome of the mate or '' if not mapped.
      def mate_chrom
        mtid = mate_tid
        return "" if mtid == -1

        String.new(LibHTS.sam_hdr_tid2name(@header.struct, mtid))
      end

      def strand
        LibHTS.bam_is_rev(@bam1) ? "-" : "+"
      end

      # def start=(v)
      #   raise 'Not Implemented'
      # end

      # insert size
      def isize
        @bam1.value.core.isize
      end

      # mapping quality
      def mapping_quality
        @bam1.value.core.qual
      end

      # returns a `Cigar` object.
      def cigar
        Cigar.new(LibHTS2.bam_get_cigar(@bam1), @bam1.value.core.n_cigar)
      end

      def qlen
        LibHTS.bam_cigar2qlen(
          @bam1[:core][:n_cigar],
          LibHTS.bam_get_cigar(@bam1)
        )
      end

      def rlen
        LibHTS.bam_cigar2rlen(
          @bam1.value.core.n_cigar,
          LibHTS.bam_get_cigar(@bam1)
        )
      end

      # return the read sequence
      def sequence
        r = LibHTS2.bam_get_seq(@bam1)
        String.build do |seq|
          (@bam1.value.core.l_qseq).times do |i|
            seq << SEQ_NT16_STR[LibHTS2.bam_seqi(r, i)]
          end
        end
      end

      # return only the base of the requested index "i" of the query sequence.
      def base_at(n)
        n += @bam1[:core][:l_qseq] if n < 0
        return "." if (n >= @bam1[:core][:l_qseq]) || (n < 0) # eg. base_at(-1000)

        r = LibHTS.bam_get_seq(@bam1)
        SEQ_NT16_STR[LibHTS.bam_seqi(r, n)]
      end

      # return the base qualities
      def base_qualities
        q_ptr = LibHTS2.bam_get_qual(@bam1)
        Array.new(@bam1.value.core.l_qseq) do |i|
          q_ptr[i]
        end
      end

      # return only the base quality of the requested index "i" of the query sequence.
      def base_quality_at(n)
        n += @bam1[:core][:l_qseq] if n < 0
        return 0 if (n >= @bam1[:core][:l_qseq]) || (n < 0) # eg. base_quality_at(-1000)

        q_ptr = LibHTS.bam_get_qual(@bam1)
        q_ptr.get_uint8(n)
      end

      def flag_str
        String.new(LibHTS.bam_flag2str(@bam1.value.core.flag))
      end

      # returns a `Flag` object.
      def flag
        Flag.new(@bam1.value.core.flag)
      end

      def tag(str)
        aux = LibHTS.bam_aux_get(@bam1, str)
        return nil if aux.null?

        t = aux.read_string(1)
        case t
        when "i", "I", "c", "C", "s", "S"
          LibHTS.bam_aux2i(aux)
        when "f", "d"
          LibHTS.bam_aux2f(aux)
        when "Z", "H"
          LibHTS.bam_aux2Z(aux)
        when "A"
          LibHTS.bam_aux2A(aux)
        end
      end

      def to_s
        kstr = Pointer(LibHTS::KstringT).malloc
        raise "Failed to format bam record" if LibHTS.sam_format1(@header.struct, @bam1, kstr) == -1

        String.new(kstr.value.s)
      end

      # TODO:
      # def eql?
      # def hash
    end
  end
end
