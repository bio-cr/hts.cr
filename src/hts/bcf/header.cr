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

      def set_version(version)
        LibHTS.bcf_hdr_set_version(@bcf_hdr, version)
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

      def add_sample(sample, sync : Bool = true)
        LibHTS.bcf_hdr_add_sample(@bcf_hdr, sample)
        self.sync if sync
      end

      def merge(hdr)
        LibHTS.bcf_hdr_merge(@bcf_hdr, hdr)
      end

      def sync
        LibHTS.bcf_hdr_sync(@bcf_hdr)
      end
      
      def read_bcf(fname)
        LibHTS.bcf_hdr_set(@bcf_hdr, fname)
      end

      def append(line)
        LibHTS.bcf_hdr_append(@bcf_hdr, line)
      end

      def delete(bcf_hl_type, key)
        type = bcf_hl_type_to_int(bcf_hl_type)
        LibHTS.bcf_hdr_remove(@bcf_hdr, type, key)
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

      private def bcf_hl_type_to_int(bcf_hl_type)
        return bcf_hl_type if bcf_hl_type.is_a?(Int32)
        case bcf_hl_type.to_s.upcase
        when "FILTER", "FIL"
          LibHTS2::BCF_HL_FLT
        when "INFO"
          LibHTS2::BCF_HL_INFO
        when "FORMAT", "FMT"
          LibHTS2::BCF_HL_FMT
        when "CONTIG", "CTG"
          LibHTS2::BCF_HL_CTG
        when "STRUCTURED", "STR"
          LibHTS2::BCF_HL_STR
        when "GENOTYPE", "GEN"
          LibHTS2::BCF_HL_GEN
        else
          raise "Unknown bcf_hl_type: #{bcf_hl_type}"
        end
      end
    end
  end
end
