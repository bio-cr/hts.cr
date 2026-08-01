module HTS
  class Bcf < Hts
    class Format
      # Borrowed view of one sample's encoded GT values.
      @[Experimental]
      struct GenotypeView
        getter values : Slice(Int32)

        def initialize(@values : Slice(Int32))
        end

        def ploidy : Int32
          @values.size
        end

        # Yields allele index, phased flag, and missing flag for each allele.
        # Missing alleles use -1 as their allele index. Vector-end sentinels are
        # excluded from this view and are not yielded.
        def each_allele(& : Int32, Bool, Bool ->) : Nil
          @values.each do |encoded|
            missing = LibHTS2.bcf_gt_is_missing(encoded) != 0
            allele_index = missing ? -1 : LibHTS2.bcf_gt_allele(encoded)
            phased = LibHTS2.bcf_gt_is_phased(encoded) != 0
            yield allele_index, phased, missing
          end
        end
      end

      def initialize(record : Bcf::Record)
        @record = record.accessor_context
      end

      def initialize(@record : Bcf::Record::AccessorContext)
      end

      def update_int(tag : String, value : Int)
        raise UnsupportedFormatOperationError.new("Use update_genotypes for GT") if tag == "GT"

        ensure_expected_format_type!(tag, :int, "integer")
        validate_numeric_sample_count!(tag, 1)

        v = value.to_i32
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_format_int32(hdr, rec, tag, pointerof(v), 1)
        check_update_rc!(rc, tag)
        rc
      end

      def update_int(tag : String, values : Array(Int32))
        raise UnsupportedFormatOperationError.new("Use update_genotypes for GT") if tag == "GT"

        ensure_expected_format_type!(tag, :int, "integer")
        validate_numeric_sample_count!(tag, values.size)

        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_format_int32(hdr, rec, tag, values.to_unsafe, values.size)
        check_update_rc!(rc, tag)
        rc
      end

      def update_float(tag : String, value : Number)
        ensure_expected_format_type!(tag, :float, "float")
        validate_numeric_sample_count!(tag, 1)

        v = value.to_f32
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_format_float(hdr, rec, tag, pointerof(v), 1)
        check_update_rc!(rc, tag)
        rc
      end

      def update_float(tag : String, values : Array(Float32))
        ensure_expected_format_type!(tag, :float, "float")
        validate_numeric_sample_count!(tag, values.size)

        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_format_float(hdr, rec, tag, values.to_unsafe, values.size)
        check_update_rc!(rc, tag)
        rc
      end

      def update_string(tag : String, value : String)
        update_string(tag, [value])
      end

      def update_string(tag : String, values : Array(String))
        raise UnsupportedFormatOperationError.new("Use update_genotypes for GT") if tag == "GT"

        ensure_expected_format_type!(tag, :string, "string")
        validate_string_sample_count!(tag, values.size)

        encoded = values.map(&.to_unsafe)
        hdr = @record.header
        rec = @record
        rc = LibHTS.bcf_update_format_string(hdr, rec, tag, encoded.to_unsafe, encoded.size)
        check_update_rc!(rc, tag)
        rc
      end

      def update_genotypes(values : Array(Int32))
        ensure_gt_defined!
        validate_numeric_sample_count!("GT", values.size)

        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_genotypes(hdr, rec, values.to_unsafe, values.size)
        check_update_rc!(rc, "GT")
        rc
      end

      def delete(tag : String) : Bool
        type = tag == "GT" ? :int : @record.header.format_type(tag)
        return false unless type
        return false unless format_present?(tag)

        bcf_type = case type
                   when :flag  then LibHTS2::BCF_HT_FLAG
                   when :int   then LibHTS2::BCF_HT_INT
                   when :float then LibHTS2::BCF_HT_REAL
                   when :string
                     LibHTS2::BCF_HT_STR
                   else
                     return false
                   end

        hdr = @record.header
        rec = @record
        rc = LibHTS.bcf_update_format(hdr, rec, tag, Pointer(Void).null, 0, bcf_type)
        raise FormatUpdateError.new("Failed to delete FORMAT/#{tag}") if rc < 0
        true
      end

      def get_int(tag) : Array(Int32)?
        get_numeric_values(tag, LibHTS2::BCF_HT_INT, Int32)
      end

      def get_float(tag) : Array(Float32)?
        get_numeric_values(tag, LibHTS2::BCF_HT_REAL, Float32)
      end

      # Yields a borrowed view of the raw Int32 FORMAT values.
      #
      # Returns false without yielding when the field is absent. The slice is
      # valid only during the block and may be invalidated earlier by another
      # FORMAT Int32 or genotype getter on the same record.
      @[Experimental]
      def with_i32_buffer(tag : String, & : Slice(Int32) ->) : Bool
        with_numeric_buffer(tag, LibHTS2::BCF_HT_INT, Int32) { |values| yield values }
      end

      # Yields a borrowed view of the raw Float32 FORMAT values.
      #
      # Returns false without yielding when the field is absent. The slice is
      # valid only during the block and may be invalidated earlier by another
      # FORMAT Float32 getter on the same record.
      @[Experimental]
      def with_f32_buffer(tag : String, & : Slice(Float32) ->) : Bool
        with_numeric_buffer(tag, LibHTS2::BCF_HT_REAL, Float32) { |values| yield values }
      end

      @[Experimental]
      def each_scalar_i32(tag : String, & : Int32, Int32 ->) : Bool
        each_scalar_numeric(tag, LibHTS2::BCF_HT_INT, Int32) { |sample_index, value| yield sample_index, value }
      end

      @[Experimental]
      def each_scalar_f32(tag : String, & : Int32, Float32 ->) : Bool
        each_scalar_numeric(tag, LibHTS2::BCF_HT_REAL, Float32) { |sample_index, value| yield sample_index, value }
      end

      @[Experimental]
      def each_vector_i32(tag : String, & : Int32, Slice(Int32) ->) : Bool
        each_vector_numeric(tag, LibHTS2::BCF_HT_INT, Int32) { |sample_index, values| yield sample_index, values }
      end

      @[Experimental]
      def each_vector_f32(tag : String, & : Int32, Slice(Float32) ->) : Bool
        each_vector_numeric(tag, LibHTS2::BCF_HT_REAL, Float32) { |sample_index, values| yield sample_index, values }
      end

      @[Experimental]
      def each_string_view(tag : String, & : Int32, Bytes ->) : Bool
        raise UnsupportedFormatOperationError.new("Use each_genotype for FORMAT/GT") if tag == "GT"
        raise_unsupported_format_flag(tag)

        scratch = @record.scratch
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_get_format_char(hdr, rec, tag, scratch.format_char_data_address, scratch.format_char_capacity_address)
        rc = normalize_format_rc(rc, tag, "string")
        return false unless rc

        fmt = LibHTS.bcf_get_fmt(hdr, rec, tag)
        raise FormatReadError.new("Failed to inspect FORMAT/#{tag}") if fmt.null?

        bytes_per_sample = fmt.value.n
        sample_count = @record.header.nsamples
        validate_format_cardinality!(tag, rc, bytes_per_sample, sample_count)

        data = scratch.format_char
        sample_index = 0
        while sample_index < sample_count
          bytes = Bytes.new(data + sample_index * bytes_per_sample, bytes_per_sample)
          size = bytes.index(0_u8) || bytes_per_sample
          yield sample_index, bytes[0, size]
          sample_index += 1
        end
        true
      end

      # Yields each sample index and a borrowed view of its encoded GT values.
      #
      # Returns false without yielding when GT is absent. A view is valid only
      # during its block invocation and excludes trailing vector-end sentinels.
      @[Experimental]
      def each_genotype(tag : String = "GT", & : Int32, GenotypeView ->) : Bool
        ensure_genotype_tag!(tag)

        with_i32_buffer(tag) do |values|
          sample_count = @record.header.nsamples
          next if sample_count <= 0

          values_per_sample = genotype_values_per_sample(values, sample_count)
          sample_index = 0
          while sample_index < sample_count
            yield sample_index, genotype_view_at(values, values_per_sample, sample_index)
            sample_index += 1
          end
        end
      end

      # Yields a borrowed GT view for one sample without traversing other
      # samples. Returns false without yielding when GT is absent.
      @[Experimental]
      def genotype_at(tag : String, sample_index : Int, & : GenotypeView ->) : Bool
        ensure_genotype_tag!(tag)
        sample_count = @record.header.nsamples
        unless 0 <= sample_index < sample_count
          raise ::IndexError.new("sample index #{sample_index} out of range 0...#{sample_count}")
        end

        with_i32_buffer(tag) do |values|
          values_per_sample = genotype_values_per_sample(values, sample_count)
          yield genotype_view_at(values, values_per_sample, sample_index)
        end
      end

      # Returns one String per sample. Character FORMAT fields are handled here too.
      def get_string(tag) : Array(String)?
        return decode_genotypes if tag == "GT"
        strings = Array(String).new(@record.header.nsamples)
        present = each_string_view(tag) do |_sample_index, bytes|
          strings << String.new(bytes)
        end
        present ? strings : nil
      end

      def genotypes : Array(Int32)?
        scratch = @record.scratch
        hdr = @record.header
        rec = @record

        rc = LibHTS2.bcf_get_genotypes(hdr, rec, scratch.format_i32_data_address, scratch.format_i32_capacity_address)
        rc = normalize_format_rc(rc, "GT", "genotype")
        return unless rc

        res = scratch.format_i32
        Array(Int32).new(rc) { |i| res[i] }
      end

      # ameba:disable Naming/AccessorMethodName
      def get_genotypes : Array(Int32)?
        genotypes
      end

      # ameba:enable Naming/AccessorMethodName

      private def get_numeric_values(tag, type, value_type : T.class) : Array(T)? forall T
        result = nil.as(Array(T)?)
        with_numeric_buffer(tag, type, value_type) do |values|
          result = values.to_a
        end
        result
      end

      private def with_numeric_buffer(tag, type, value_type : T.class, & : Slice(T) ->) : Bool forall T
        raise_unsupported_format_flag(tag)
        hdr = @record.header
        rec = @record
        rc = 0

        {% if T == Int32 %}
          rc = LibHTS.bcf_get_format_values(
            hdr,
            rec,
            tag,
            @record.scratch.format_i32_data_address,
            @record.scratch.format_i32_capacity_address,
            type
          )
        {% elsif T == Float32 %}
          rc = LibHTS.bcf_get_format_values(
            hdr,
            rec,
            tag,
            @record.scratch.format_f32_data_address,
            @record.scratch.format_f32_capacity_address,
            type
          )
        {% else %}
          {% raise "Unsupported FORMAT scratch type: #{T}" %}
        {% end %}

        expected_type = value_type == Float32 ? "float" : "integer"
        rc = normalize_format_rc(rc, tag, expected_type)
        return false unless rc

        {% if T == Int32 %}
          yield Slice(T).new(@record.scratch.format_i32, rc)
        {% else %}
          yield Slice(T).new(@record.scratch.format_f32, rc)
        {% end %}
        true
      end

      private def each_scalar_numeric(tag, type, value_type : T.class, & : Int32, T ->) : Bool forall T
        with_numeric_buffer(tag, type, value_type) do |values|
          sample_count = @record.header.nsamples
          values_per_sample = format_values_per_sample(tag, values.size, sample_count)
          unless values_per_sample == 1
            raise FormatReadError.new("FORMAT/#{tag} has #{values_per_sample} values per sample; use the vector iterator")
          end

          sample_index = 0
          while sample_index < sample_count
            yield sample_index, values[sample_index]
            sample_index += 1
          end
        end
      end

      private def each_vector_numeric(tag, type, value_type : T.class, & : Int32, Slice(T) ->) : Bool forall T
        with_numeric_buffer(tag, type, value_type) do |values|
          sample_count = @record.header.nsamples
          values_per_sample = format_values_per_sample(tag, values.size, sample_count)

          sample_index = 0
          while sample_index < sample_count
            offset = sample_index * values_per_sample
            sample_values = values[offset, values_per_sample]
            end_index = sample_values.index do |value|
              {% if T == Int32 %}
                LibHTS2.bcf_int32_is_vector_end(value) != 0
              {% else %}
                LibHTS2.bcf_float_is_vector_end(value) != 0
              {% end %}
            end || sample_values.size
            yield sample_index, sample_values[0, end_index]
            sample_index += 1
          end
        end
      end

      private def format_values_per_sample(tag : String, value_count : Int32, sample_count : Int32) : Int32
        if sample_count <= 0 || value_count % sample_count != 0
          raise FormatReadError.new("Failed to split FORMAT/#{tag} values by sample")
        end
        value_count // sample_count
      end

      private def validate_format_cardinality!(tag : String, value_count : Int32, values_per_sample : Int32, sample_count : Int32) : Nil
        if values_per_sample <= 0 || sample_count <= 0 || value_count != values_per_sample * sample_count
          raise FormatReadError.new("Failed to split FORMAT/#{tag} values by sample")
        end
      end

      private def raise_unsupported_format_flag(tag : String)
        raise UnsupportedFormatOperationError.new("FORMAT flag fields are not supported: #{tag}") if @record.header.format_type(tag) == :flag
      end

      private def ensure_expected_format_type!(tag : String, expected_type : Symbol, expected_label : String)
        actual_type = tag == "GT" ? :string : @record.header.format_type(tag)
        raise FormatDefinitionError.new("FORMAT tag #{tag} not defined in header") unless actual_type

        raise_unsupported_format_flag(tag)
        raise FormatTypeError.new("Tag #{tag} is not #{expected_label} FORMAT field") unless actual_type == expected_type
      end

      private def ensure_gt_defined!
        raise FormatDefinitionError.new("FORMAT tag GT not defined in header") unless @record.header.format_type("GT")
      end

      private def validate_numeric_sample_count!(tag : String, value_count : Int32)
        sample_count = @record.header.nsamples
        raise FormatUpdateError.new("FORMAT fields require at least one sample") if sample_count <= 0
        return if value_count % sample_count == 0

        raise FormatUpdateError.new("FORMAT values for #{tag} must be divisible by sample count (#{sample_count})")
      end

      private def validate_string_sample_count!(tag : String, value_count : Int32)
        sample_count = @record.header.nsamples
        raise FormatUpdateError.new("FORMAT fields require at least one sample") if sample_count <= 0
        return if value_count == sample_count

        raise FormatUpdateError.new("FORMAT string values for #{tag} must provide one entry per sample (#{sample_count})")
      end

      private def check_update_rc!(rc : Int32, tag : String)
        case rc
        when -1
          raise FormatDefinitionError.new("FORMAT tag #{tag} not defined in header")
        when 0
          rc
        else
          raise FormatUpdateError.new("Failed to update FORMAT/#{tag}") if rc < 0
          rc
        end
      end

      private def normalize_format_rc(rc : Int32, tag : String, expected_type : String) : Int32?
        case rc
        when -1
          raise FormatDefinitionError.new("FORMAT tag #{tag} not defined in header")
        when -3
          nil
        when -2
          raise FormatTypeError.new("Tag #{tag} is not #{expected_type} FORMAT field")
        when -4
          raise FormatReadError.new("Failed to read FORMAT/#{tag}")
        else
          rc
        end
      end

      private def decode_genotypes : Array(String)?
        strings = Array(String).new(@record.header.nsamples)
        present = each_genotype do |_sample_index, genotype|
          strings << decode_genotype_sample(genotype)
        end
        present ? strings : nil
      end

      private def decode_genotype_sample(genotype : GenotypeView) : String
        io = IO::Memory.new
        wrote_allele = false

        genotype.each_allele do |allele_index, phased, missing|
          if wrote_allele
            separator = phased ? '|' : '/'
            io << separator
          end

          if missing
            io << '.'
          else
            io << allele_index
          end

          wrote_allele = true
        end

        io.to_s
      end

      private def ensure_genotype_tag!(tag : String) : Nil
        raise ArgumentError.new("Genotype traversal only supports FORMAT/GT") unless tag == "GT"
      end

      private def genotype_values_per_sample(values : Slice(Int32), sample_count : Int32) : Int32
        format_values_per_sample("GT", values.size, sample_count)
      end

      private def genotype_view_at(values : Slice(Int32), values_per_sample : Int32, sample_index : Int) : GenotypeView
        offset = sample_index * values_per_sample
        sample_values = values[offset, values_per_sample]
        end_index = sample_values.index do |value|
          LibHTS2.bcf_gt_is_vector_end(value) != 0
        end || sample_values.size
        GenotypeView.new(sample_values[0, end_index])
      end

      private def format_present?(tag : String) : Bool
        if tag == "GT"
          !get_genotypes.nil?
        else
          case @record.header.format_type(tag)
          when :int
            !get_int(tag).nil?
          when :float
            !get_float(tag).nil?
          when :string
            !get_string(tag).nil?
          else
            false
          end
        end
      end
    end
  end
end
