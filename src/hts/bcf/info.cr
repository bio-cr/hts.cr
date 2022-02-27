module HTS
  class Bcf
    class Info
      def initialize(@record : Bcf::Record)
        @p1 = Pointer(Void).null
      end

      # FIXME: API This API is tentative and needs to be modified to be consistent with Ruby.

      def get_int(tag)
        ndst = Pointer(Int32).malloc
        dst = pointerof(@p1)
        hdr = @record.header.struct
        r = @record.struct
        if LibHTS2.bcf_get_info_int32(hdr, r, tag, dst, ndst) < 0
          return nil
        end
        res = Pointer(Int32).new(@p1.address)
        Array(Int32).new(ndst[0]) { |i| res[i] }
      end

      def get_float(tag)
        ndst = Pointer(Int32).malloc
        dst = pointerof(@p1)
        hdr = @record.header.struct
        r = @record.struct
        if LibHTS2.bcf_get_info_float(hdr, r, tag, dst, ndst) < 0
          return nil
        end
        res = Pointer(Float32).new(@p1.address)
        Array(Float32).new(ndst[0]) { |i| res[i] }
      end

      def get_string(tag)
        ndst = Pointer(Int32).malloc
        dst = pointerof(@p1)
        hdr = @record.header.struct
        r = @record.struct
        if LibHTS2.bcf_get_info_string(hdr, r, tag, dst, ndst) < 0
          return nil
        end
        String.new(Pointer(UInt8).new(@p1.address))
      end

      def get_flag(tag)
        ndst = Pointer(Int32).malloc
        dst = pointerof(@p1)
        hdr = @record.header.struct
        r = @record.struct
        case LibHTS2.bcf_get_info_flag(hdr, r, tag, dst, ndst)
        when 1
          return true
        when 0
          return false
        when -1
          return nil
        else
          raise "unknown return value"
        end
      end
    end
  end
end
