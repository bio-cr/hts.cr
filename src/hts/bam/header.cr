module HTS
  class Bam < Hts
    class Header
      HD_TAG_MAP = {
        :version     => "VN",
        :sort_order  => "SO",
        :group_order => "GO",
        :subsorting  => "SS",
      }

      SQ_TAG_MAP = {
        :name      => "SN",
        :length    => "LN",
        :assembly  => "AS",
        :md5       => "M5",
        :species   => "SP",
        :uri       => "UR",
        :alt_names => "AN",
      }

      RG_TAG_MAP = {
        :id                => "ID",
        :sample            => "SM",
        :library           => "LB",
        :platform          => "PL",
        :platform_unit     => "PU",
        :center            => "CN",
        :description       => "DS",
        :date              => "DT",
        :flow_order        => "FO",
        :key_sequence      => "KS",
        :program           => "PG",
        :insert_size       => "PI",
        :molecule_topology => "PM",
      }

      def self.parse(text)
        sam_hdr = LibHTS.sam_hdr_parse(text.size, text)
        raise ArgumentError.new("Failed to parse SAM header text") if sam_hdr.null?
        new sam_hdr
      end

      def initialize(hts_file : Pointer(HTS::LibHTS::HtsFile))
        @sam_hdr = LibHTS.sam_hdr_read(hts_file)
        raise "Failed to read SAM header" if @sam_hdr.null?
      end

      # for clone
      def initialize(sam_hdr : Pointer(HTS::LibHTS::SamHdrT))
        @sam_hdr = sam_hdr
        raise ArgumentError.new("SAM header pointer must not be null") if @sam_hdr.null?
      end

      def initialize
        @sam_hdr = LibHTS.sam_hdr_init
        raise "Failed to initialize SAM header" if @sam_hdr.null?
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
          tid2name(i)
        end
      end

      def target_len
        Array.new(target_count) do |i|
          LibHTS.sam_hdr_tid2len(@sam_hdr, i)
        end
      end

      def append(line : String)
        text = ensure_newline(line)
        rc = LibHTS.sam_hdr_add_lines(@sam_hdr, text, text.bytesize)
        raise "Failed to append SAM header line" if rc < 0
        self
      end

      def find_line(type : String, id_key : String? = nil, id_value : String? = nil) : String?
        kstr = empty_kstring
        begin
          rc = LibHTS.sam_hdr_find_line_id(@sam_hdr, type, cstr(id_key), cstr(id_value), pointerof(kstr))
          rc == 0 ? String.new(kstr.s) : nil
        ensure
          LibC.free(kstr.s) unless kstr.s.null?
        end
      end

      def find_tag(type : String, id_key : String?, id_value : String?, key : String) : String?
        kstr = empty_kstring
        begin
          rc = LibHTS.sam_hdr_find_tag_id(@sam_hdr, type, cstr(id_key), cstr(id_value), key, pointerof(kstr))
          rc == 0 ? String.new(kstr.s) : nil
        ensure
          LibC.free(kstr.s) unless kstr.s.null?
        end
      end

      def delete_line(type : String, id_key : String? = nil, id_value : String? = nil) : Bool
        LibHTS.sam_hdr_remove_line_id(@sam_hdr, type, cstr(id_key), cstr(id_value)) == 0
      end

      def delete_tag(type : String, id_key : String?, id_value : String?, key : String) : Bool
        LibHTS.sam_hdr_remove_tag_id(@sam_hdr, type, cstr(id_key), cstr(id_value), key) == 1
      end

      def count_lines(type : String) : Int32
        LibHTS.sam_hdr_count_lines(@sam_hdr, type)
      end

      def line_index(type : String, key : String) : Int32
        LibHTS.sam_hdr_line_index(@sam_hdr, type, key)
      end

      def line_name(type : String, pos : Int) : String?
        name = LibHTS.sam_hdr_line_name(@sam_hdr, type, pos)
        name.null? ? nil : String.new(name)
      end

      def update_hd(**tags)
        pairs = merge_sam_pairs(find_line_pairs("HD", nil, nil), normalize_sam_tags(tags, HD_TAG_MAP))
        replace_sam_line("HD", nil, nil, pairs, ["VN", "SO", "GO", "SS"])
        self
      end

      def add_sq(name : String, length : Int, **tags)
        pairs = [{"SN", name}, {"LN", length.to_s}]
        pairs.concat normalize_sam_tags(tags, SQ_TAG_MAP)
        add_structured_sam_line("SQ", pairs, ["SN", "LN", "AS", "M5", "SP", "UR", "AN"])
        self
      end

      def update_sq(name : String, **tags)
        pairs = merge_identified_sam_line("SQ", "SN", name, normalize_sam_tags(tags, SQ_TAG_MAP), ["SN"])
        replace_sam_line("SQ", "SN", name, pairs, ["SN", "LN", "AS", "M5", "SP", "UR", "AN"])
        self
      end

      def remove_sq(name : String) : Bool
        delete_line("SQ", "SN", name)
      end

      def add_rg(id : String, **tags)
        pairs = [{"ID", id}]
        pairs.concat normalize_sam_tags(tags, RG_TAG_MAP)
        add_structured_sam_line("RG", pairs, ["ID", "SM", "LB", "PL", "PU", "CN", "DS", "DT", "FO", "KS", "PG", "PI", "PM"])
        self
      end

      def update_rg(id : String, **tags)
        pairs = merge_identified_sam_line("RG", "ID", id, normalize_sam_tags(tags, RG_TAG_MAP), ["ID"])
        replace_sam_line("RG", "ID", id, pairs, ["ID", "SM", "LB", "PL", "PU", "CN", "DS", "DT", "FO", "KS", "PG", "PI", "PM"])
        self
      end

      def remove_rg(id : String) : Bool
        delete_line("RG", "ID", id)
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
        name = LibHTS.sam_hdr_tid2name(@sam_hdr, tid)
        raise ArgumentError.new("Unknown target id #{tid}") if name.null?
        String.new(name)
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

      private def empty_kstring : LibHTS::KstringT
        kstr = LibHTS::KstringT.new
        kstr.l = 0
        kstr.m = 0
        kstr.s = Pointer(LibC::Char).null
        kstr
      end

      private def cstr(value : String?)
        value ? value.to_unsafe : Pointer(LibC::Char).null
      end

      private def normalize_sam_tags(tags, tag_map) : Array({String, String})
        pairs = [] of {String, String}
        tags.each do |key, value|
          sam_key = tag_map[key]? || key.to_s.upcase
          sam_value = value.is_a?(Array) ? value.join(",") : value.to_s
          raise ArgumentError.new("Header tag keys must not be empty") if sam_key.empty?
          if sam_value.includes?('\t') || sam_value.includes?('\n') || sam_value.includes?('\r')
            raise ArgumentError.new("Header tag values must not contain tabs or newlines")
          end
          pairs << {sam_key, sam_value}
        end
        pairs
      end

      private def parse_sam_pairs(line : String) : Array({String, String})
        fields = line.chomp.split('\t')
        pairs = [] of {String, String}
        fields[1..].each do |field|
          key, value = field.split(':', 2)
          pairs << {key, value || ""}
        end
        pairs
      end

      private def find_line_pairs(type : String, id_key : String?, id_value : String?) : Array({String, String})
        line = find_line(type, id_key, id_value)
        line ? parse_sam_pairs(line) : [] of {String, String}
      end

      private def merge_identified_sam_line(type : String, id_key : String, id_value : String, updates : Array({String, String}), protected_keys : Array(String)) : Array({String, String})
        line = find_line(type, id_key, id_value)
        raise ArgumentError.new("Header line not found: @#{type} #{id_key}:#{id_value}") unless line
        merge_sam_pairs(parse_sam_pairs(line), updates, protected_keys)
      end

      private def merge_sam_pairs(existing_pairs : Array({String, String}), updates : Array({String, String}), protected_keys : Array(String) = [] of String) : Array({String, String})
        pairs = existing_pairs.map { |key, value| {key, value} }
        updates.each do |key, value|
          if protected_keys.includes?(key)
            existing = existing_pairs.find { |pair| pair[0] == key }
            raise ArgumentError.new("Header tag #{key} cannot be updated") if existing && existing[1] != value
            next
          end

          index = pairs.index { |pair| pair[0] == key }
          if index
            pairs[index] = {key, value}
          else
            pairs << {key, value}
          end
        end
        pairs
      end

      private def add_structured_sam_line(type : String, pairs : Array({String, String}), preferred_order : Array(String))
        append(build_sam_line(type, pairs, preferred_order))
      end

      private def replace_sam_line(type : String, id_key : String?, id_value : String?, pairs : Array({String, String}), preferred_order : Array(String))
        delete_line(type, id_key, id_value)
        append(build_sam_line(type, pairs, preferred_order))
      end

      private def build_sam_line(type : String, pairs : Array({String, String}), preferred_order : Array(String)) : String
        ordered_pairs = [] of {String, String}
        preferred_order.each do |wanted|
          pair = pairs.find { |item| item[0] == wanted }
          ordered_pairs << pair if pair
        end
        pairs.each do |pair|
          ordered_pairs << pair unless preferred_order.includes?(pair[0])
        end
        "@#{type}\t#{ordered_pairs.map { |key, value| "#{key}:#{value}" }.join('\t')}\n"
      end

      private def ensure_newline(text : String) : String
        text.ends_with?('\n') ? text : "#{text}\n"
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
