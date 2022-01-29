module HTS
  class Bam
    class Header
      def initialize(hts_file : Pointer(HTS::LibHTS::HtsFile))
        @sam_hdr = LibHTS.sam_hdr_read(hts_file)
      end

      # for clone
      def initialize(sam_hdr : Pointer(HTS::LibHTS::SamHdrT))
        @sam_hdr = sam_hdr
      end

      def struct
        @sam_hdr
      end

      def target_count
        @sam_hdr.value.n_targets
      end

      # FIXME: better name?
      def seqs
        Array.new(@sam_hdr[:n_targets]) do |i|
          LibHTS.sam_hdr_tid2name(@sam_hdr, i)
        end
      end

      def to_s
        String.new(LibHTS.sam_hdr_str(@sam_hdr))
      end

      def clone
        self.class.new(LibHTS.sam_hdr_dup(@sam_hdr))
      end
    end
  end
end
