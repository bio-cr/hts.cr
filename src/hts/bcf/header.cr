module HTS
  class Bcf
    class Header
      def initialize(bcf_hdr : Pointer(HTS::LibHTS::HtsFile))
        @bcf_hdr = LibHTS.bcf_hdr_read(bcf_hdr)
      end

      def struct
        @bcf_hdr
      end

      def to_s
        kstr = LibHTS::KstringT.new
        unless LibHTS.bcf_hdr_format(@bcf_hdr, 0, pointerof(kstr))
          raise "Failed to format header"
        end
        String.new(kstr.s)
      end
    end
  end
end
