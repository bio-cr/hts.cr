module HTS
  class Bcf
    class Header
      def initialize(hts_file : Pointer(HTS::LibHTS::HtsFile))
        @bcf_hdr = LibHTS.bcf_hdr_read(hts_file)
      end

      # for clone
      def initialize(bcf_hdr : Pointer(HTS::LibHTS::BcfHdrT))
        @bcf_hdr = bcf_hdr
      end

      def struct
        @bcf_hdr
      end

      def get_version
        String.new(LibHTS.bcf_hdr_get_version(@bcf_hdr))
      end

      def sample_count
        LibHTS2.bcf_hdr_nsamples(@bcf_hdr)
      end

      def to_s
        kstr = LibHTS::KstringT.new
        unless LibHTS.bcf_hdr_format(@bcf_hdr, 0, pointerof(kstr))
          raise "Failed to format header"
        end
        String.new(kstr.s)
      end

      def clone
        self.class.new(LibHTS.bcf_hdr_dup(@bcf_hdr))
      end
    end
  end
end
