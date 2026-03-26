module HTS
  class Bcf < Hts
    class Format
      def initialize(@record : Bcf::Record)
      end

      def get_int(tag) : Array(Int32)?
        get_numeric_values(tag, LibHTS2::BCF_HT_INT, Int32)
      end

      def get_float(tag) : Array(Float32)?
        get_numeric_values(tag, LibHTS2::BCF_HT_REAL, Float32)
      end

      # Returns one String per sample. FORMAT/GT is decoded into genotype strings.
      def get_string(tag) : Array(String)?
        return decode_genotypes if tag == "GT"

        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        rec = @record

        rc = LibHTS2.bcf_get_format_char(hdr, rec, tag, pointerof(dst), pointerof(ndst))
        rc = normalize_format_rc(rc, tag, "string")
        return nil unless rc

        fmt = LibHTS.bcf_get_fmt(hdr, rec, tag)
        raise "Failed to inspect FORMAT/#{tag}" if fmt.null?

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

      private def get_float_samples(tag : String) : Array(Array(Float32))?
        values = get_float(tag)
        return nil unless values
        split_float_samples(values)
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

      private def normalize_format_rc(rc : Int32, tag : String, expected_type : String) : Int32?
        case rc
        when -1, -3
          nil
        when -2
          raise "Tag #{tag} is not #{expected_type} FORMAT field"
        when -4
          raise "Failed to read FORMAT/#{tag}"
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

      private def split_float_samples(values : Array(Float32)) : Array(Array(Float32))
        split_sample_values(values).map { |sample_values| trim_float_vector_end(sample_values) }
      end

      private def split_sample_values(values : Array(T)) : Array(Array(T)) forall T
        sample_count = @record.header.nsamples
        return [] of Array(T) if sample_count <= 0

        if values.size % sample_count != 0
          raise "Failed to split FORMAT values by sample"
        end

        values_per_sample = values.size // sample_count
        Array(Array(T)).new(sample_count) do |sample_index|
          start = sample_index * values_per_sample
          values[start, values_per_sample]
        end
      end

      private def trim_integer_vector_end(values : Array(Int32)) : Array(Int32)
        vector_end = Int32::MIN + 1
        end_index = values.index(vector_end) || values.size
        values[0, end_index]
      end

      private def trim_genotype_vector_end(values : Array(Int32)) : Array(Int32)
        end_index = values.index { |value| LibHTS2.bcf_gt_is_vector_end(value) != 0 } || values.size
        values[0, end_index]
      end

      private def trim_float_vector_end(values : Array(Float32)) : Array(Float32)
        end_index = values.index { |value| LibHTS.bcf_float_is_vector_end(value) != 0 } || values.size
        values[0, end_index]
      end
    end
  end
end
