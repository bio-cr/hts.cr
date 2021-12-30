module HTS
  class Bcf
    class Header
      def initialize(bcf_hdr : Pointer(HTS::LibHTS::BcfHdrT))
        @bcf_hdr = bcf_hdr
      end

      def struct
        @bcf_hdr 
      end
    end
  end
end
