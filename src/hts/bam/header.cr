module HTS
  class Bam < Hts
    class Header
      def self.parse(text)
        self.new LibHTS.sam_hdr_parse(text.size, text)
      end

      def initialize(hts_file : Pointer(HTS::LibHTS::HtsFile))
        @sam_hdr = LibHTS.sam_hdr_read(hts_file)
      end

      # for clone
      def initialize(sam_hdr : Pointer(HTS::LibHTS::SamHdrT))
        @sam_hdr = sam_hdr
      end

      def initialize
        @sam_hdr = LibHTS.sam_hdr_init
      end

      def to_unsafe
        @sam_hdr
      end

      def target_count
        @sam_hdr.value.n_targets
      end

      def target_names
        Array.new(target_count) do |i|
          String.new LibHTS.sam_hdr_tid2name(@sam_hdr, i)
        end
      end

      def target_len
        Array.new(target_count) do |i|
          LibHTS.sam_hdr_tid2len(@sam_hdr, i)
        end
      end

      def add_pg(name, *args)
        LibHTS.sam_hdr_add_pg(@sam_hdr, name, *args, nil)
      end

      def name2tid(name)
        LibHTS.sam_hdr_name2tid(@sam_hdr, name)
      end

      def tid2name(tid)
        String.new LibHTS.sam_hdr_tid2name(@sam_hdr, tid)
      end

      def to_s(io : IO)
        io << String.new LibHTS.sam_hdr_str(@sam_hdr)
      end

      def clone
        self.class.new LibHTS.sam_hdr_dup(@sam_hdr)
      end

      def finalize
        LibHTS.sam_hdr_destroy @sam_hdr unless @sam_hdr.null?
      end
    end
  end
end
