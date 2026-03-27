module HTS
  class Bcf < Hts
    class Info
      def initialize(@record : Bcf::Record)
      end

      # Character INFO fields are routed through the string path.
      def [](tag : String) : Array(Int32) | Array(Float32) | String | Bool | Nil
        case @record.header.info_type(tag)
        when :flag
          get_flag(tag)
        when :int
          get_int(tag)
        when :float
          get_float(tag)
        when :string
          get_string(tag)
        else
          nil
        end
      end

      def get_int(tag) : Array(Int32)?
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_int32(hdr, r, tag, pointerof(dst), pointerof(ndst))
        rc = normalize_info_rc(rc, tag, "integer")
        return nil unless rc
        begin
          res = dst.as(Pointer(Int32))
          Array(Int32).new(rc) { |i| res[i] }
        ensure
          LibHTS.hts_free(dst) unless dst.null?
        end
      end

      def get_int64(tag) : Array(Int64)?
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_int64(hdr, r, tag, pointerof(dst), pointerof(ndst))
        rc = normalize_info_rc(rc, tag, "integer")
        return nil unless rc
        begin
          res = dst.as(Pointer(Int64))
          Array(Int64).new(rc) { |i| res[i] }
        ensure
          LibHTS.hts_free(dst) unless dst.null?
        end
      end

      def get_int_opt(tag) : Array(Int32?)?
        ints = get_int(tag)
        return nil unless ints
        ints.map { |v| LibHTS2.bcf_int32_is_missing(v) != 0 ? nil : v }
      end

      def get_int64_opt(tag) : Array(Int64?)?
        ints = get_int64(tag)
        return nil unless ints
        ints.map { |v| LibHTS2.bcf_int64_is_missing(v) != 0 ? nil : v }
      end

      def get_float(tag) : Array(Float32)?
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_float(hdr, r, tag, pointerof(dst), pointerof(ndst))
        rc = normalize_info_rc(rc, tag, "float")
        return nil unless rc
        begin
          res = dst.as(Pointer(Float32))
          Array(Float32).new(rc) { |i| res[i] }
        ensure
          LibHTS.hts_free(dst) unless dst.null?
        end
      end

      def get_float_opt(tag) : Array(Float32?)?
        floats = get_float(tag)
        return nil unless floats
        floats.map { |v| LibHTS2.bcf_float_is_missing(v) != 0 ? nil : v }
      end

      def get_string(tag) : String?
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        r = @record
        rc = LibHTS2.bcf_get_info_string(hdr, r, tag, pointerof(dst), pointerof(ndst))
        rc = normalize_info_rc(rc, tag, "string")
        return nil unless rc
        begin
          String.new dst.as(Pointer(UInt8))
        ensure
          LibHTS.hts_free(dst) unless dst.null?
        end
      end

      def get_flag(tag) : Bool?
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        r = @record
        case LibHTS2.bcf_get_info_flag(hdr, r, tag, pointerof(dst), pointerof(ndst))
        when 1
          val = true
        when 0
          val = false
        when -3
          val = false
        when -1
          val = nil
        when -2
          raise "Tag #{tag} is not a flag INFO field"
        when -4
          raise "Failed to read INFO/#{tag}"
        else
          raise "unknown return value"
        end
        LibHTS.hts_free(dst) unless dst.null?
        val
      end

      def update_int(tag : String, value : Int)
        update_int(tag, [value.to_i32])
      end

      def update_int(tag : String, values : Array(Int32))
        hdr = @record.header
        rec = @record
        rc = LibHTS2.bcf_update_info_int32(hdr, rec, tag, values.to_unsafe, values.size)
        check_update_rc!(rc, tag)
        rc
      end

      def update_int64(tag : String, value : Int)
        update_int64(tag, [value.to_i64])
      end

      def update_int64(tag : String, values : Array(Int64))
        # FIXME
        raise "htslib backend does not implement int64 INFO update (BCF_HT_LONG)"
      end

      def update_float(tag : String, value : Number)
        update_float(tag, [value.to_f32])
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
        when -1, -3
          nil
        when -2
          raise "Tag #{tag} is not #{expected_type} INFO field"
        when -4
          raise "Failed to read INFO/#{tag}"
        else
          rc
        end
      end

      private def check_update_rc!(rc : Int32, tag : String)
        raise "Failed to update INFO/#{tag}" if rc < 0
      end
    end
  end
end
