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
        missing = Int32::MIN
        ints.map { |v| v == missing ? nil : v }
      end

      def get_int64_opt(tag) : Array(Int64?)?
        ints = get_int64(tag)
        return nil unless ints
        missing = Int64::MIN
        ints.map { |v| v == missing ? nil : v }
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
        floats.map { |v| LibHTS.bcf_float_is_missing(v) != 0 ? nil : v }
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
    end
  end
end
