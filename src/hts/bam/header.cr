module HTS
  class Bam
    class Header
      def initialize(pointer : Pointer(HTS::LibHTS::HtsFile))
        @sam_hdr = LibHTS.sam_hdr_read(pointer)
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

      def to_s
        String.new(LibHTS.sam_hdr_str(@sam_hdr))
      end
    end
  end
end
