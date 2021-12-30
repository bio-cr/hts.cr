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
    end
  end
end
