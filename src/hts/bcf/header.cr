module HTS
  class Bcf < Hts
    class Header
      BCF_TYPE_MAP = {
        :int       => "Integer",
        :integer   => "Integer",
        :int32     => "Integer",
        :float     => "Float",
        :real      => "Float",
        :string    => "String",
        :str       => "String",
        :character => "Character",
        :char      => "Character",
        :flag      => "Flag",
      }

      def initialize(hts_file : Pointer(HTS::LibHTS::HtsFile))
        @bcf_hdr = LibHTS.bcf_hdr_read(hts_file)
        raise "Failed to read BCF/VCF header" if @bcf_hdr.null?

        @sync_depth = 0
        @sync_needed = false
        @subset_samples = nil
        @subset_imap = nil
        @subset_imap_buffer = Pointer(Int32).null
      end

      # for clone
      def initialize(bcf_hdr : Pointer(HTS::LibHTS::BcfHdrT))
        @bcf_hdr = bcf_hdr
        raise ArgumentError.new("BCF/VCF header pointer must not be null") if @bcf_hdr.null?

        @sync_depth = 0
        @sync_needed = false
        @subset_samples = nil
        @subset_imap = nil
        @subset_imap_buffer = Pointer(Int32).null
      end

      def initialize
        @bcf_hdr = LibHTS.bcf_hdr_init("w")
        raise "Failed to initialize BCF/VCF header" if @bcf_hdr.null?

        @sync_depth = 0
        @sync_needed = false
        @subset_samples = nil
        @subset_imap = nil
        @subset_imap_buffer = Pointer(Int32).null
      end

      def to_unsafe
        @bcf_hdr
      end

      def get_version
        String.new LibHTS.bcf_hdr_get_version(@bcf_hdr)
      end

      def set_version(version)
        rc = LibHTS.bcf_hdr_set_version(@bcf_hdr, version)
        raise "Failed to set VCF header version" if rc < 0
        mark_sync_needed!
        sync_if_needed!
        self
      end

      def nsamples
        LibHTS2.bcf_hdr_nsamples(@bcf_hdr)
      end

      def target_count : Int32
        target_names.size.to_i32
      end

      def name2id(name : String) : Int32
        LibHTS2.bcf_hdr_name2id(self, name)
      end

      def get_tid(name : String) : Int32
        name2id(name)
      end

      def target_name(rid : Int32) : String
        String.new LibHTS2.bcf_hdr_id2name(self, rid)
      end

      def target_names : Array(String)
        nseqs = 0
        names = LibHTS.bcf_hdr_seqnames(@bcf_hdr, pointerof(nseqs))
        begin
          return [] of String if names.null? || nseqs <= 0

          Array(String).new(nseqs) do |index|
            String.new(names[index])
          end
        ensure
          LibHTS.hts_free(names.as(Void*)) unless names.null?
        end
      end

      # Character is reported as :string because htslib exposes both via BCF_HT_STR.
      def info_type(tag : String)
        tag_type(tag, LibHTS2::BCF_HL_INFO)
      end

      # Character is reported as :string because htslib exposes both via BCF_HT_STR.
      def format_type(tag : String)
        tag_type(tag, LibHTS2::BCF_HL_FMT)
      end

      def samples
        # bcf_hdr_id2name is macro function
        Array.new(nsamples) do |i|
          String.new @bcf_hdr.value.samples[i]
        end
      end

      getter subset_samples

      def subset? : Bool
        !@subset_imap.nil?
      end

      def subset_sample_count : Int32
        return 0_i32 unless subset_samples = @subset_samples

        subset_samples.size.to_i32
      end

      def subset_imap_buffer : Pointer(Int32)
        @subset_imap_buffer
      end

      def subset(sample_names : Enumerable(String))
        names = normalize_subset_samples(sample_names)
        validate_subset_samples!(names)

        sample_ptrs = Pointer(Pointer(LibC::Char)).null
        imap_buffer = Pointer(Int32).null
        encoded_samples = [] of Pointer(LibC::Char)

        unless names.empty?
          encoded_samples = names.map(&.to_unsafe)
          sample_ptrs = encoded_samples.to_unsafe
          imap_buffer = Pointer(Int32).malloc(names.size)
        end

        subset_hdr = LibHTS.bcf_hdr_subset(@bcf_hdr, names.size, sample_ptrs, imap_buffer)
        raise SubsetError.new("Failed to subset BCF header samples #{names.inspect}") if subset_hdr.null?

        header = self.class.new(subset_hdr)
        header.set_subset_state(names, compose_subset_imap(read_subset_imap(imap_buffer, names.size)))
        header
      end

      def add_sample(sample, sync : Bool = true)
        rc = LibHTS.bcf_hdr_add_sample(@bcf_hdr, sample)
        raise "Failed to add sample #{sample}" if rc < 0
        mark_sync_needed!
        sync_if_needed! if sync
        self
      end

      def merge(hdr)
        merged = LibHTS.bcf_hdr_merge(@bcf_hdr, hdr)
        raise "Failed to merge BCF headers" if merged.null?
        mark_sync_needed!
        sync_if_needed!
        self
      end

      def sync
        rc = LibHTS.bcf_hdr_sync(@bcf_hdr)
        raise "Failed to sync BCF header" if rc < 0
        @sync_needed = false
        self
      end

      def read_bcf(fname)
        LibHTS.bcf_hdr_set(@bcf_hdr, fname)
      end

      def append(line)
        rc = LibHTS.bcf_hdr_append(@bcf_hdr, line)
        raise "Failed to append VCF header line" if rc < 0
        mark_sync_needed!
        self
      end

      def delete(bcf_hl_type, key = nil)
        existed = hrec_exists?(bcf_hl_type, key)
        type = bcf_hl_type_to_int(bcf_hl_type)
        LibHTS.bcf_hdr_remove(@bcf_hdr, type, cstr(key))
        mark_sync_needed! if existed
        existed
      end

      def edit(&)
        @sync_depth += 1
        yield self
        self
      ensure
        @sync_depth -= 1
        sync_if_needed!
      end

      def add_contig(id : String, length : Int? = nil, **attributes)
        fields = [{"ID", id}]
        fields << {"length", length.to_s} if length
        fields.concat normalize_meta_attributes(attributes)
        append_structured_meta("contig", fields)
      end

      def remove_contig(id : String) : Bool
        delete("CONTIG", id).tap { sync_if_needed! }
      end

      def add_filter(id : String, description : String, **attributes)
        fields = [{"ID", id}, {"Description", description}]
        fields.concat normalize_meta_attributes(attributes)
        append_structured_meta("FILTER", fields)
      end

      def remove_filter(id : String) : Bool
        delete("FILTER", id).tap { sync_if_needed! }
      end

      def add_info(id : String, *, number, type, description : String, **attributes)
        fields = [{"ID", id}, {"Number", normalize_bcf_number(number)}, {"Type", normalize_bcf_type(type)}, {"Description", description}]
        fields.concat normalize_meta_attributes(attributes)
        append_structured_meta("INFO", fields)
      end

      def update_info(id : String, *, number, type, description : String, **attributes)
        delete("INFO", id)
        fields = [{"ID", id}, {"Number", normalize_bcf_number(number)}, {"Type", normalize_bcf_type(type)}, {"Description", description}]
        fields.concat normalize_meta_attributes(attributes)
        append_structured_meta("INFO", fields)
      end

      def remove_info(id : String) : Bool
        delete("INFO", id).tap { sync_if_needed! }
      end

      def add_format(id : String, *, number, type, description : String, **attributes)
        fields = [{"ID", id}, {"Number", normalize_bcf_number(number)}, {"Type", normalize_bcf_type(type)}, {"Description", description}]
        fields.concat normalize_meta_attributes(attributes)
        append_structured_meta("FORMAT", fields)
      end

      def update_format(id : String, *, number, type, description : String, **attributes)
        delete("FORMAT", id)
        fields = [{"ID", id}, {"Number", normalize_bcf_number(number)}, {"Type", normalize_bcf_type(type)}, {"Description", description}]
        fields.concat normalize_meta_attributes(attributes)
        append_structured_meta("FORMAT", fields)
      end

      def remove_format(id : String) : Bool
        delete("FORMAT", id).tap { sync_if_needed! }
      end

      def add_meta(key : String, value : String? = nil, **attributes)
        if attributes.size == 0
          append("###{key}=#{value}")
          sync_if_needed!
          self
        else
          append_structured_meta(key, normalize_meta_attributes(attributes))
        end
      end

      def to_s(io : IO)
        kstr = LibHTS::KstringT.new
        kstr.l = 0
        kstr.m = 0
        kstr.s = Pointer(LibC::Char).null

        begin
          rc = LibHTS.bcf_hdr_format(@bcf_hdr, 0, pointerof(kstr))
          raise "Failed to format header" if rc < 0

          io << (String.new kstr.s)
        ensure
          LibC.free(kstr.s) unless kstr.s.null?
        end
      end

      def clone
        header = self.class.new(LibHTS.bcf_hdr_dup(@bcf_hdr))
        if subset_imap = @subset_imap
          if subset_samples = @subset_samples
            header.set_subset_state(subset_samples.dup, subset_imap.dup)
          end
        end
        header
      end

      def finalize
        LibHTS.bcf_hdr_destroy(@bcf_hdr) unless @bcf_hdr.null?
      end

      private def cstr(value : String?)
        value ? value.to_unsafe : Pointer(LibC::Char).null
      end

      protected def set_subset_state(samples : Array(String), imap : Array(Int32)) : Nil
        @subset_samples = samples.dup
        @subset_imap = imap.dup
        if imap.empty?
          @subset_imap_buffer = Pointer(Int32).null
        else
          @subset_imap_buffer = Pointer(Int32).malloc(imap.size)
          imap.each_with_index do |value, index|
            @subset_imap_buffer[index] = value
          end
        end
      end

      private def normalize_subset_samples(sample_names : Enumerable(String)) : Array(String)
        sample_names.map(&.to_s).to_a
      end

      private def validate_subset_samples!(subset_samples : Array(String)) : Nil
        duplicates = subset_samples.group_by { |name| name }.compact_map do |name, group|
          name if group.size > 1
        end
        unless duplicates.empty?
          raise SubsetError.new("Duplicate sample names in subset: #{duplicates.join(", ")}")
        end

        missing = subset_samples.reject { |name| samples.includes?(name) }
        unless missing.empty?
          raise UnknownSampleError.new("Unknown sample names: #{missing.join(", ")}")
        end
      end

      private def read_subset_imap(imap_buffer : Pointer(Int32), length : Int) : Array(Int32)
        return [] of Int32 if length == 0

        Array(Int32).new(length) { |index| imap_buffer[index] }
      end

      private def compose_subset_imap(imap : Array(Int32)) : Array(Int32)
        base_imap = @subset_imap || Array(Int32).new(samples.size) { |index| index.to_i32 }
        imap.map { |index| base_imap[index] }
      end

      private def normalize_bcf_type(type) : String
        if type.is_a?(Symbol)
          BCF_TYPE_MAP[type]? || type.to_s
        else
          type.to_s
        end
      end

      private def normalize_bcf_number(number) : String
        case number
        when Symbol
          case number
          when :a, :A                then "A"
          when :r, :R                then "R"
          when :g, :G                then "G"
          when :variable, :var, :dot then "."
          else
            number.to_s
          end
        else
          number.to_s
        end
      end

      private def normalize_meta_attributes(attributes) : Array({String, String})
        fields = [] of {String, String}
        attributes.each do |key, value|
          meta_key = key.to_s.split('_').map_with_index { |part, index| index == 0 ? part : part.capitalize }.join
          meta_value = value.is_a?(Array) ? value.join(",") : value.to_s
          fields << {meta_key, meta_value}
        end
        fields
      end

      private def append_structured_meta(label : String, fields : Array({String, String}))
        body = fields.map { |key, value| "#{key}=#{format_meta_value(key, value)}" }.join(",")
        append("###{label}=<#{body}>")
        sync_if_needed!
        self
      end

      private def format_meta_value(key : String, value : String) : String
        return quote_meta_value(value) if key == "Description"
        return value if value.matches?(/\A[[:alnum:]_.:+-]+\z/)
        quote_meta_value(value)
      end

      private def quote_meta_value(value : String) : String
        '"' + value.gsub(/([\\"])/, "\\\\\\1") + '"'
      end

      private def mark_sync_needed! : Nil
        @sync_needed = true
      end

      private def sync_if_needed! : Nil
        sync if @sync_needed && @sync_depth == 0
      end

      private def hrec_exists?(bcf_hl_type, key) : Bool
        type = bcf_hl_type_to_int(bcf_hl_type)
        lookup_key, lookup_value, str_class = hrec_lookup_args(type, key)
        hrec = LibHTS.bcf_hdr_get_hrec(@bcf_hdr, type, cstr(lookup_key), cstr(lookup_value), cstr(str_class))
        !hrec.null?
      end

      private def hrec_lookup_args(type : Int32, key : String?)
        case type
        when LibHTS2::BCF_HL_FLT, LibHTS2::BCF_HL_INFO, LibHTS2::BCF_HL_FMT, LibHTS2::BCF_HL_CTG
          {"ID", key, nil}
        when LibHTS2::BCF_HL_GEN
          {key, nil, nil}
        else
          {"ID", key, nil}
        end
      end

      private def tag_type(tag : String, header_line_type : Int32)
        id = LibHTS.bcf_hdr_id2int(@bcf_hdr, LibHTS2::BCF_DT_ID, tag)
        return nil if id < 0

        case LibHTS2.bcf_hdr_id2type(self, header_line_type, id)
        when LibHTS2::BCF_HT_FLAG
          :flag
        when LibHTS2::BCF_HT_INT
          :int
        when LibHTS2::BCF_HT_REAL
          :float
        when LibHTS2::BCF_HT_STR
          :string
        end
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
