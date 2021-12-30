module HTS
  class Bcf
    class Record
      def initialize(bcf_t : Pointer(HTS::LibHTS::Bcf1T), header : Bcf::Header)
        @bcf1 = bcf_t
        @header = header
      end

      def pos
        @bcf1.value.pos + 1
      end

      def start
        @bcf1.value.pos
      end

      def stop
        @bcf1.value.pos + @bcf1.value.rlen
      end

      def id
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_INFO)
        String.new(@bcf1.value.d.id)
      end

      def qual
        @bcf1.value.qual
      end

      def ref
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_STR)
        String.new(@bcf1.value.d.allele[0])
      end

      def to_s
        ksr = LibHTS::KstringT.new
        raise "Failed to format record" if LibHTS.vcf_format(@header.struct, @bcf1, pointerof(ksr)) == -1

        String.new(ksr.s)
      end
    end
  end
end
