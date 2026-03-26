module HTS
  class Bcf < Hts
    class Info
      def initialize(@record : Bcf::Record)
      end

      # Dynamic access using the declared INFO type from the header.
      #
      # Returns one of:
      # - Array(Int32)
      # - Array(Float32)
      # - String
      # - Bool
      # - nil
      def [](tag : String)
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

      # Get INFO int32 array. Returns nil if tag not present.
      #
      # Low-level contract:
      # - returns nil for undefined tags and tags absent in the record
      # - raises on type mismatch and internal htslib failures
      # - preserves raw sentinel values; use *_opt helpers to map missing values
      def get_int(tag)
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

      # Get INFO int64 array. Returns nil if tag not present.
      def get_int64(tag)
        ndst = 0
        dst = Pointer(Void).null
        hdr = @record.header
        r = @record
        # Use base function with LONG type explicitly (not all wrappers expose int64 helper)
        rc = LibHTS.bcf_get_info_values(hdr, r, tag, pointerof(dst), pointerof(ndst), LibHTS2::BCF_HT_LONG)
        rc = normalize_info_rc(rc, tag, "integer")
        return nil unless rc
        begin
          res = dst.as(Pointer(Int64))
          Array(Int64).new(rc) { |i| res[i] }
        ensure
          LibHTS.hts_free(dst) unless dst.null?
        end
      end

      # Get INFO int32 array with missing values mapped to nil.
      # Missing is encoded in BCF as INT32_MIN; vector_end should not appear in INFO but is ignored if present.
      def get_int_opt(tag)
        ints = get_int(tag)
        return nil unless ints
        missing = Int32::MIN
        ints.map { |v| v == missing ? nil : v }
      end

      # Get INFO float array. Returns nil if tag not present.
      # Raw floating-point sentinels are preserved. Use get_float_opt to map
      # missing values to nil.
      def get_float(tag)
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

      # Get INFO float array with missing values mapped to nil (bcf_float_missing is a NaN sentinel)
      def get_float_opt(tag)
        floats = get_float(tag)
        return nil unless floats
        floats.map { |v| LibHTS.bcf_float_is_missing(v) != 0 ? nil : v.to_f64 }
      end

      # Get INFO string. Returns nil if tag not present.
      def get_string(tag)
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

      # Get INFO flag.
      #
      # Low-level contract:
      # - returns nil for undefined tags
      # - returns false when the flag is defined but absent in the record
      # - raises on type mismatch and internal htslib failures
      def get_flag(tag)
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
        # typically no allocation for flags, but free if htslib did allocate
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
