module HTS
  class Bcf
    class Format
      def initialize(@record : Bcf::Record)
        @p1 = Pointer(Void).null
      end

      {% for type in [["int", "Int32", "BCF_HT_INT"],
                      ["float", "Float32", "BCF_HT_REAL"]]%}
        def get_{{type[0].id}}(key)
          n = Pointer(Int32).malloc
          p1 = pointerof(@p1)
          h = @record.header.struct
          r = @record.struct

          LibHTS.bcf_get_format_values(h, r, key, p1, n, HTS::LibHTS2::{{type[2].id}})
          res = Pointer({{type[1].id}}).new(@p1.address)
          Array({{type[1].id}}).new(n[0]){|i| res[i]}
        end
      {% end %}
    end
  end
end
