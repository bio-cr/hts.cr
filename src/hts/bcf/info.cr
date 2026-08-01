module HTS
  class Bcf < Hts
    class Info
      def initialize(@record : Bcf::Record)
      end

      def get_int(tag) : Array(Int32)?
        scratch = @record.scratch
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_int32(hdr, r, tag, scratch.info_i32_data_address, scratch.info_i32_capacity_address)
        rc = normalize_info_rc(rc, tag, "integer")
        return unless rc
        res = scratch.info_i32
        Array(Int32).new(rc) { |i| res[i] }
      end

      def get_int64(tag) : Array(Int64)?
        scratch = @record.scratch
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_int64(hdr, r, tag, scratch.info_i64_data_address, scratch.info_i64_capacity_address)
        rc = normalize_info_rc(rc, tag, "integer")
        return unless rc
        res = scratch.info_i64
        Array(Int64).new(rc) { |i| res[i] }
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
        scratch = @record.scratch
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_float(hdr, r, tag, scratch.info_f32_data_address, scratch.info_f32_capacity_address)
        rc = normalize_info_rc(rc, tag, "float")
        return unless rc
        res = scratch.info_f32
        Array(Float32).new(rc) { |i| res[i] }
      end

      def get_float_opt(tag) : Array(Float32?)?
        floats = get_float(tag)
        return unless floats
        floats.map { |v| LibHTS2.bcf_float_is_missing(v) != 0 ? nil : v }
      end

      def get_string(tag) : String?
        scratch = @record.scratch
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_string(hdr, r, tag, scratch.info_char_data_address, scratch.info_char_capacity_address)
        rc = normalize_info_rc(rc, tag, "string")
        return unless rc
        String.new scratch.info_char
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

      private def check_update_rc!(rc : Int32, tag : String)
        raise InfoUpdateError.new("Failed to update INFO/#{tag}") if rc < 0
      end
    end
  end
end
