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

      def target_name(tid)
        tid2name(tid)
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
        line = build_pg_line(name.to_s, args)
        result = LibHTS.sam_hdr_add_lines(@sam_hdr, line, line.bytesize)
        raise "Failed to add @PG line" if result < 0
        self
      end

      private def name2tid(name)
        LibHTS.sam_hdr_name2tid(@sam_hdr, name)
      end

      private def tid2name(tid)
        String.new LibHTS.sam_hdr_tid2name(@sam_hdr, tid)
      end

      def to_s(io : IO)
        io << String.new LibHTS.sam_hdr_str(@sam_hdr)
      end

      # experimental
      def get_tid(name)
        name2tid(name)
      end

      def clone
        self.class.new LibHTS.sam_hdr_dup(@sam_hdr)
      end

      private def build_pg_line(name : String, args) : String
        ordered_tags = normalize_pg_tags(name, parse_pg_tags(args))
        "@PG\t#{ordered_tags.map { |key, value| "#{key}:#{value}" }.join('\t')}\n"
      end

      private def parse_pg_tags(args) : Array({String, String})
        values = args.to_a.map(&.to_s)
        raise ArgumentError.new("PG tags must be key/value pairs") if values.size.odd?

        tags = [] of {String, String}
        index = 0
        while index < values.size
          key = values[index]
          value = values[index + 1]
          validate_pg_tag(key, value)
          tags << {key, value}
          index += 2
        end
        tags
      end

      private def normalize_pg_tags(name : String, tags : Array({String, String})) : Array({String, String})
        existing_ids = pg_ids
        tag_map = tags.to_h
        pg_id = resolve_pg_id(name, tag_map, existing_ids)
        validate_pg_parent(tag_map["PP"]?, existing_ids)

        ordered_tags = [] of {String, String}
        ordered_tags << {"ID", pg_id}
        ordered_tags << {"PN", tag_map["PN"]? || name}
        tags.each do |key, value|
          next if key == "ID" || key == "PN"
          ordered_tags << {key, value}
        end
        ordered_tags
      end

      private def validate_pg_tag(key : String, value : String) : Nil
        raise ArgumentError.new("PG tag keys must not be empty") if key.empty?
        if value.includes?('\t') || value.includes?('\n') || value.includes?('\r')
          raise ArgumentError.new("PG tag values must not contain tabs or newlines")
        end
      end

      private def resolve_pg_id(name : String, tag_map : Hash(String, String), existing_ids : Array(String)) : String
        pg_id = tag_map["ID"]? || next_pg_id(name, existing_ids)
        if tag_map["ID"]? && existing_ids.includes?(pg_id)
          raise ArgumentError.new("PG ID already exists: #{pg_id}")
        end
        pg_id
      end

      private def validate_pg_parent(parent_id : String?, existing_ids : Array(String)) : Nil
        if parent_id && !existing_ids.includes?(parent_id)
          raise ArgumentError.new("Unknown PG parent: #{parent_id}")
        end
      end

      private def next_pg_id(name : String, existing_ids : Array(String)) : String
        candidate = name
        suffix = 0
        while existing_ids.includes?(candidate)
          suffix += 1
          candidate = "#{name}.#{suffix}"
        end
        candidate
      end

      private def pg_ids : Array(String)
        ids = [] of String
        to_s.each_line do |line|
          next unless line.starts_with?("@PG\t")

          line.chomp.split('\t')[1..].each do |field|
            key, value = field.split(':', 2)
            if key == "ID" && value
              ids << value
              break
            end
          end
        end
        ids
      end

      def finalize
        LibHTS.sam_hdr_destroy @sam_hdr unless @sam_hdr.null?
      end
    end
  end
end
