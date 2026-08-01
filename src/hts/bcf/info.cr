module HTS
  class Bcf < Hts
    class Info
      def initialize(record : Bcf::Record)
        @record = record.accessor_context
      end

      def initialize(@record : Bcf::Record::AccessorContext)
      end

      def get_int(tag) : Array(Int32)?
        result = nil.as(Array(Int32)?)
        with_i32_buffer(tag) { |values| result = values.to_a }
        result
      end

      def get_int64(tag) : Array(Int64)?
        result = nil.as(Array(Int64)?)
        with_i64_buffer(tag) { |values| result = values.to_a }
        result
      end

      def get_int_opt(tag) : Array(Int32?)?
        ints = get_int(tag)
        return unless ints
        ints.map { |v| LibHTS2.bcf_int32_is_missing(v) != 0 ? nil : v }
      end

      def get_int64_opt(tag) : Array(Int64?)?
        ints = get_int64(tag)
        return unless ints
        ints.map { |v| LibHTS2.bcf_int64_is_missing(v) != 0 ? nil : v }
      end

      def get_float(tag) : Array(Float32)?
        result = nil.as(Array(Float32)?)
        with_f32_buffer(tag) { |values| result = values.to_a }
        result
      end

      # Yields a borrowed view of the raw Int32 INFO values.
      #
      # Returns false without yielding when the field is absent. The slice is
      # valid only during the block and may be invalidated earlier by another
      # INFO Int32 getter on the same record.
      @[Experimental]
      def with_i32_buffer(tag : String, & : Slice(Int32) ->) : Bool
        with_numeric_buffer(tag, "integer", Int32) { |values| yield values }
      end

      # Yields a borrowed view of the raw Int64 INFO values.
      #
      # Returns false without yielding when the field is absent. The slice is
      # valid only during the block and may be invalidated earlier by another
      # INFO Int64 getter on the same record.
      @[Experimental]
      def with_i64_buffer(tag : String, & : Slice(Int64) ->) : Bool
        with_numeric_buffer(tag, "integer", Int64) { |values| yield values }
      end

      # Yields a borrowed view of the raw Float32 INFO values.
      #
      # Returns false without yielding when the field is absent. The slice is
      # valid only during the block and may be invalidated earlier by another
      # INFO Float32 getter on the same record.
      @[Experimental]
      def with_f32_buffer(tag : String, & : Slice(Float32) ->) : Bool
        with_numeric_buffer(tag, "float", Float32) { |values| yield values }
      end

      def get_float_opt(tag) : Array(Float32?)?
        floats = get_float(tag)
        return unless floats
        floats.map { |v| LibHTS2.bcf_float_is_missing(v) != 0 ? nil : v }
      end

      def get_string(tag) : String?
        result = nil.as(String?)
        with_string_view(tag) { |bytes| result = String.new(bytes) }
        result
      end

      @[Experimental]
      def with_string_view(tag : String, & : Bytes ->) : Bool
        scratch = @record.scratch
        hdr = @record.header
        record = @record
        rc = LibHTS2.bcf_get_info_string(hdr, record, tag, scratch.info_char_data_address, scratch.info_char_capacity_address)
        rc = normalize_info_rc(rc, tag, "string")
        return false unless rc

        yield Bytes.new(scratch.info_char, rc)
        true
      end

      def get_flag(tag) : Bool?
        scratch = @record.scratch
        hdr = @record.header
        r = @record
        case LibHTS2.bcf_get_info_flag(hdr, r, tag, scratch.info_flag_data_address, scratch.info_flag_capacity_address)
        when 1
          val = true
        when 0
          val = false
        when -3
          val = false
        when -1
          raise InfoDefinitionError.new("INFO tag #{tag} not defined in header")
        when -2
          raise InfoTypeError.new("Tag #{tag} is not a flag INFO field")
        when -4
          raise InfoReadError.new("Failed to read INFO/#{tag}")
        else
          raise InfoReadError.new("Unknown return value from bcf_get_info_flag")
        end
        val
      end

      def update_int(tag : String, value : Int)
        v = value.to_i32
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_info_int32(hdr, rec, tag, pointerof(v), 1)
        check_update_rc!(rc, tag)
        rc
      end

      def update_int(tag : String, values : Array(Int32))
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_info_int32(hdr, rec, tag, values.to_unsafe, values.size)
        check_update_rc!(rc, tag)
        rc
      end

      def update_int64(tag : String, value : Int)
        raise UnsupportedInfoOperationError.new("htslib backend does not implement int64 INFO update (BCF_HT_LONG)")
      end

      def update_int64(tag : String, values : Array(Int64))
        # FIXME
        raise UnsupportedInfoOperationError.new("htslib backend does not implement int64 INFO update (BCF_HT_LONG)")
      end

      def update_float(tag : String, value : Number)
        v = value.to_f32
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_info_float(hdr, rec, tag, pointerof(v), 1)
        check_update_rc!(rc, tag)
        rc
      end

      def update_float(tag : String, values : Array(Float32))
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_info_float(hdr, rec, tag, values.to_unsafe, values.size)
        check_update_rc!(rc, tag)
        rc
      end

      def update_string(tag : String, value : String)
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_info_string(hdr, rec, tag, value)
        check_update_rc!(rc, tag)
        rc
      end

      def update_flag(tag : String, present : Bool = true)
        hdr = @record.header
        rec = @record
        n = present ? 1 : 0
        rc = LibHTS2.bcf_update_info_flag(hdr, rec, tag, Pointer(Void).null, n)
        check_update_rc!(rc, tag)
        rc
      end

      def delete(tag : String) : Bool
        type = @record.header.info_type(tag)
        return false unless type

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
        rc = LibHTS.bcf_update_info(hdr, rec, tag, Pointer(Void).null, 0, bcf_type)
        rc >= 0
      end

      private def normalize_info_rc(rc : Int32, tag : String, expected_type : String) : Int32?
        case rc
        when -1
          raise InfoDefinitionError.new("INFO tag #{tag} not defined in header")
        when -3
          nil
        when -2
          raise InfoTypeError.new("Tag #{tag} is not #{expected_type} INFO field")
        when -4
          raise InfoReadError.new("Failed to read INFO/#{tag}")
        else
          rc
        end
      end

      private def with_numeric_buffer(tag : String, expected_type : String, value_type : T.class, & : Slice(T) ->) : Bool forall T
        scratch = @record.scratch
        hdr = @record.header
        record = @record
        rc = 0

        {% if T == Int32 %}
          rc = LibHTS2.bcf_get_info_int32(hdr, record, tag, scratch.info_i32_data_address, scratch.info_i32_capacity_address)
        {% elsif T == Int64 %}
          rc = LibHTS2.bcf_get_info_int64(hdr, record, tag, scratch.info_i64_data_address, scratch.info_i64_capacity_address)
        {% elsif T == Float32 %}
          rc = LibHTS2.bcf_get_info_float(hdr, record, tag, scratch.info_f32_data_address, scratch.info_f32_capacity_address)
        {% else %}
          {% raise "Unsupported INFO scratch type: #{T}" %}
        {% end %}

        rc = normalize_info_rc(rc, tag, expected_type)
        return false unless rc

        {% if T == Int32 %}
          yield Slice(T).new(scratch.info_i32, rc)
        {% elsif T == Int64 %}
          yield Slice(T).new(scratch.info_i64, rc)
        {% else %}
          yield Slice(T).new(scratch.info_f32, rc)
        {% end %}
        true
      end

      private def check_update_rc!(rc : Int32, tag : String)
        raise InfoUpdateError.new("Failed to update INFO/#{tag}") if rc < 0
      end
    end
  end
end
