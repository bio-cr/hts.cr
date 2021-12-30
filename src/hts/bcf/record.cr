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
    end
  end
end
