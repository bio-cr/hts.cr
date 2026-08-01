module HTS
  class Bcf < Hts
    # Internal reusable storage for values returned by HTSlib BCF getters.
    #
    # The pointers are stored directly in this object. A record therefore adds
    # only one scratch object, rather than one wrapper allocation per buffer.
    # :nodoc:
    class Scratch
      {% begin %}
        {% buffers = {
             format_i32:  Int32,
             format_f32:  Float32,
             format_char: UInt8,
             info_i32:    Int32,
             info_i64:    Int64,
             info_f32:    Float32,
             info_char:   UInt8,
             info_flag:   UInt8,
           } %}

        {% for name, type in buffers %}
          @{{name.id}}_data = Pointer(Void).null
          @{{name.id}}_capacity = 0

          def {{name.id}} : Pointer({{type}})
            @{{name.id}}_data.as(Pointer({{type}}))
          end

          def {{name.id}}_capacity : Int32
            @{{name.id}}_capacity
          end

          def {{name.id}}_data_address : Pointer(Pointer(Void))
            pointerof(@{{name.id}}_data)
          end

          def {{name.id}}_capacity_address : Pointer(Int32)
            pointerof(@{{name.id}}_capacity)
          end
        {% end %}

        def close : Nil
          {% for name, _type in buffers %}
            LibHTS.hts_free(@{{name.id}}_data) unless @{{name.id}}_data.null?
            @{{name.id}}_data = Pointer(Void).null
            @{{name.id}}_capacity = 0
          {% end %}
        end
      {% end %}
    end
  end
end
