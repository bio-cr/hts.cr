module HTS
  class Bcf < Hts
    class Header
      def initialize(hts_file : Pointer(HTS::LibHTS::HtsFile))
        @bcf_hdr = LibHTS.bcf_hdr_read(hts_file)
      end

      # for clone
      def initialize(bcf_hdr : Pointer(HTS::LibHTS::BcfHdrT))
        @bcf_hdr = bcf_hdr
      end

      def initialize
        @bcf_hdr = LibHTS.bcf_hdr_init("w")
      end

      def to_unsafe
        @bcf_hdr
      end

      def get_version
        String.new LibHTS.bcf_hdr_get_version(@bcf_hdr)
      end

      def nsamples
        LibHTS2.bcf_hdr_nsamples(@bcf_hdr)
      end

      def samples
        # bcf_hdr_id2name is macro function
        Array.new(nsamples) do |i|
          String.new @bcf_hdr.value.samples[i]
        end
      end

      def to_s(io : IO)
        kstr = LibHTS::KstringT.new
        unless LibHTS.bcf_hdr_format(@bcf_hdr, 0, pointerof(kstr))
          raise "Failed to format header"
        end
        io << (String.new kstr.s)
      end

      def clone
        self.class.new(LibHTS.bcf_hdr_dup(@bcf_hdr))
      end

      def finalize
        LibHTS.bcf_hdr_destroy(@bcf_hdr) unless @bcf_hdr.null?
      end
    end
  end
end
