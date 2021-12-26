module HTS
  class Bam
    class Header
      def initialize(pointer : Pointer(HTS::LibHTS::SamHdrT))
        @sam_hdr = pointer
      end

      def struct
        @sam_hdr
      end

      # FIXME: better name?
      def seqs
        Array.new(@sam_hdr[:n_targets]) do |i|
          LibHTS.sam_hdr_tid2name(@sam_hdr, i)
        end
      end

      def text
        LibHTS.sam_hdr_str(@sam_hdr)
      end
    end
  end
end
