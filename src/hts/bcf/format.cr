module HTS
  class Bcf < Hts
    class Format
      def initialize(@record : Bcf::Record)
      end

      def update_int(tag : String, value : Int)
        update_int(tag, [value.to_i32])
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
        update_float(tag, [value.to_f32])
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
        raise_unsupported_format_flag(tag)
        get_numeric_values(tag, LibHTS2::BCF_HT_INT, Int32)
      end

      def get_float(tag) : Array(Float32)?
        raise_unsupported_format_flag(tag)
        get_numeric_values(tag, LibHTS2::BCF_HT_REAL, Float32)
      end

      # Returns one String per sample. Character FORMAT fields are handled here too.
      def get_string(tag) : Array(String)?
        return decode_genotypes if tag == "GT"
        raise_unsupported_format_flag(tag)

        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        rec = @record

        rc = LibHTS2.bcf_get_format_char(hdr, rec, tag, pointerof(dst), pointerof(ndst))
        rc = normalize_format_rc(rc, tag, "string")
        return nil unless rc

        fmt = LibHTS.bcf_get_fmt(hdr, rec, tag)
        raise FormatReadError.new("Failed to inspect FORMAT/#{tag}") if fmt.null?

        begin
          bytes_per_sample = fmt.value.n
          return [] of String if bytes_per_sample <= 0

          buffer = dst.as(Pointer(UInt8))
          sample_count = rc // bytes_per_sample

          Array(String).new(sample_count) do |sample_index|
            offset = sample_index * bytes_per_sample
            slice = Bytes.new(buffer + offset, bytes_per_sample)
            size = slice.index(0_u8) || bytes_per_sample
            String.new(slice[0, size])
          end
        ensure
          LibHTS.hts_free(dst) unless dst.null?
        end
      end

      def get_genotypes : Array(Int32)?
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        rec = @record

        rc = LibHTS2.bcf_get_genotypes(hdr, rec, pointerof(dst), pointerof(ndst))
        rc = normalize_format_rc(rc, "GT", "genotype")
        return nil unless rc

        begin
          res = dst.as(Pointer(Int32))
          Array(Int32).new(rc) { |i| res[i] }
        ensure
          LibHTS.hts_free(dst) unless dst.null?
        end
      end

      private def get_int_samples(tag : String) : Array(Array(Int32))?
        values = get_int(tag)
        return nil unless values
        split_integer_samples(values)
      end

      private def get_int_samples_opt(tag : String) : Array(Array(Int32?))?
        values = get_int(tag)
        return nil unless values
        split_integer_samples_opt(values)
      end

      private def get_float_samples(tag : String) : Array(Array(Float32))?
        values = get_float(tag)
        return nil unless values
        split_float_samples(values)
      end

      private def get_float_samples_opt(tag : String) : Array(Array(Float32?))?
        values = get_float(tag)
        return nil unless values
        split_float_samples_opt(values)
      end

      private def get_numeric_values(tag, type, value_type : T.class) : Array(T)? forall T
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        rec = @record

        rc = LibHTS.bcf_get_format_values(hdr, rec, tag, pointerof(dst), pointerof(ndst), type)
        expected_type = value_type == Float32 ? "float" : "integer"
        rc = normalize_format_rc(rc, tag, expected_type)
        return nil unless rc

        begin
          res = dst.as(Pointer(T))
          Array(T).new(rc) { |i| res[i] }
        ensure
          LibHTS.hts_free(dst) unless dst.null?
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
        raise "FORMAT fields require at least one sample" if sample_count <= 0
        return if value_count % sample_count == 0

        raise "FORMAT values for #{tag} must be divisible by sample count (#{sample_count})"
      end

      private def validate_string_sample_count!(tag : String, value_count : Int32)
        sample_count = @record.header.nsamples
        raise "FORMAT fields require at least one sample" if sample_count <= 0
        return if value_count == sample_count

        raise "FORMAT string values for #{tag} must provide one entry per sample (#{sample_count})"
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
        when -1, -3
          nil
        when -2
          raise FormatTypeError.new("Tag #{tag} is not #{expected_type} FORMAT field")
        when -4
          raise FormatReadError.new("Failed to read FORMAT/#{tag}")
        else
          rc
        end
      end

      private def get_genotype_samples : Array(Array(Int32))?
        encoded = get_genotypes
        return nil unless encoded
        split_sample_values(encoded).map { |sample_values| trim_genotype_vector_end(sample_values) }
      end

      private def decode_genotypes : Array(String)?
        sample_values = get_genotype_samples
        return nil unless sample_values
        sample_values.map { |values| decode_genotype_sample(values) }
      end

      private def decode_genotype_sample(values : Array(Int32)) : String
        io = IO::Memory.new
        wrote_allele = false

        values.each do |value|
          if wrote_allele
            separator = LibHTS2.bcf_gt_is_phased(value) != 0 ? '|' : '/'
            io << separator
          end

          if LibHTS2.bcf_gt_is_missing(value) != 0
            io << '.'
          else
            io << LibHTS2.bcf_gt_allele(value)
          end

          wrote_allele = true
        end

        io.to_s
      end

      private def split_integer_samples(values : Array(Int32)) : Array(Array(Int32))
        split_sample_values(values).map { |sample_values| trim_integer_vector_end(sample_values) }
      end

      private def split_integer_samples_opt(values : Array(Int32)) : Array(Array(Int32?))
        split_sample_values(values).map { |sample_values| map_integer_missing(trim_integer_vector_end(sample_values)) }
      end

      private def split_float_samples(values : Array(Float32)) : Array(Array(Float32))
        split_sample_values(values).map { |sample_values| trim_float_vector_end(sample_values) }
      end

      private def split_float_samples_opt(values : Array(Float32)) : Array(Array(Float32?))
        split_sample_values(values).map { |sample_values| map_float_missing(trim_float_vector_end(sample_values)) }
      end

      private def split_sample_values(values : Array(T)) : Array(Array(T)) forall T
        sample_count = @record.header.nsamples
        return [] of Array(T) if sample_count <= 0

        if values.size % sample_count != 0
          raise FormatReadError.new("Failed to split FORMAT values by sample")
        end

        values_per_sample = values.size // sample_count
        Array(Array(T)).new(sample_count) do |sample_index|
          start = sample_index * values_per_sample
          values[start, values_per_sample]
        end
      end

      private def trim_integer_vector_end(values : Array(Int32)) : Array(Int32)
        end_index = values.index { |value| LibHTS2.bcf_int32_is_vector_end(value) != 0 } || values.size
        values[0, end_index]
      end

      private def trim_genotype_vector_end(values : Array(Int32)) : Array(Int32)
        end_index = values.index { |value| LibHTS2.bcf_gt_is_vector_end(value) != 0 } || values.size
        values[0, end_index]
      end

      private def trim_float_vector_end(values : Array(Float32)) : Array(Float32)
        end_index = values.index { |value| LibHTS2.bcf_float_is_vector_end(value) != 0 } || values.size
        values[0, end_index]
      end

      private def map_integer_missing(values : Array(Int32)) : Array(Int32?)
        values.map { |value| LibHTS2.bcf_int32_is_missing(value) != 0 ? nil : value }
      end

      private def map_float_missing(values : Array(Float32)) : Array(Float32?)
        values.map { |value| LibHTS2.bcf_float_is_missing(value) != 0 ? nil : value }
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
