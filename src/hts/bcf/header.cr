module HTS
  class Bcf
    class Header
      def initialize(pointer : Pointer(HTS::LibHTS::BcfHdrT))
        @pointer = pointer
      end
    end
  end
end
