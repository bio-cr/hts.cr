# This file is named auxi.cr because aux.cr causes issues on Windows.

module HTS
  class Bam < Hts
    AUX_TAG_PATTERN = /\A[A-Za-z][A-Za-z0-9]\z/

    def self.aux_tag_to_static_array(tag : String) : StaticArray(UInt8, 2)
      unless tag.matches?(AUX_TAG_PATTERN)
        raise ArgumentError.new("AUX tag must match /[A-Za-z][A-Za-z0-9]/: #{tag.inspect}")
      end

      bytes = tag.to_slice
      StaticArray(UInt8, 2).new { |i| bytes[i] }
    end

    # Provides iteration over auxiliary tags in BAM records
    #
    # This class enables efficient access to all auxiliary tags
    # using HTSlib's bam_aux_first and bam_aux_next functions.
    #
    # Usage examples:
    #   # Iterate over all tags
    #   record.aux.each do |tag, value|
    #     puts "#{tag}: #{value}"
    #   end
    #
    #   # Access specific tags with stable return types
    #   as_score = record.aux.get_int("AS")
    class Aux
      # include Enumerable # DO NOT

      AUX_INT_TYPES        = {'c'.ord.to_u8, 'C'.ord.to_u8, 's'.ord.to_u8, 'S'.ord.to_u8, 'i'.ord.to_u8, 'I'.ord.to_u8}
      AUX_FLOAT_TYPES      = {'f'.ord.to_u8, 'd'.ord.to_u8}
      AUX_STRING_TYPES     = {'Z'.ord.to_u8, 'H'.ord.to_u8}
      AUX_ARRAY_TYPE       = 'B'.ord.to_u8
      AUX_CHAR_TYPE        = 'A'.ord.to_u8
      AUX_FLOAT_ARRAY_TYPE = 'f'.ord.to_u8

      def initialize(@bam1 : Pointer(LibHTS::Bam1T))
      end

      # Iterate over all auxiliary tags
      def each(&)
        aux_ptr = LibHTS.bam_aux_first(@bam1)
        while !aux_ptr.null?
          tag = String.new(aux_ptr - 2, 2)
          value = parse_aux_value(aux_ptr)
          yield tag, value
          aux_ptr = LibHTS.bam_aux_next(@bam1, aux_ptr)
        end
      end

      # Iterate over all auxiliary tags with original BAM type information.
      def each_with_type(&)
        aux_ptr = LibHTS.bam_aux_first(@bam1)
        while !aux_ptr.null?
          tag = String.new(aux_ptr - 2, 2)
          value, original_type = parse_aux_value_with_type(aux_ptr)
          if original_type
            type = original_type == 'B' ? "B:#{(aux_ptr + 1).value.chr}" : original_type.to_s
            yield tag, type, value
          end
          aux_ptr = LibHTS.bam_aux_next(@bam1, aux_ptr)
        end
      end

      # Returns the integer value for *tag*, `nil` when absent, and raises
      # `AuxTypeError` when the tag exists with a non-integer type.
      def get_int(tag : String) : Int64?
        aux_ptr = get_aux_pointer(tag)
        return if aux_ptr.null?
        ensure_aux_type!(tag, aux_ptr, "integer") { |type| AUX_INT_TYPES.includes?(type) }

        LibHTS.bam_aux2i(aux_ptr)
      end

      # Returns the float value for *tag*, `nil` when absent, and raises
      # `AuxTypeError` when the tag exists with a non-float type.
      def get_float(tag : String) : Float64?
        aux_ptr = get_aux_pointer(tag)
        return if aux_ptr.null?
        ensure_aux_type!(tag, aux_ptr, "float") { |type| AUX_FLOAT_TYPES.includes?(type) }

        LibHTS.bam_aux2f(aux_ptr)
      end

      # Returns the string value for *tag*, `nil` when absent, and raises
      # `AuxTypeError` when the tag exists with a non-string type.
      def get_string(tag : String) : String?
        aux_ptr = get_aux_pointer(tag)
        return if aux_ptr.null?
        ensure_aux_type!(tag, aux_ptr, "string") { |type| AUX_STRING_TYPES.includes?(type) }

        String.new LibHTS.bam_aux2_z(aux_ptr)
      end

      # Returns the character value for *tag*, `nil` when absent, and raises
      # `AuxTypeError` when the tag exists with a non-character type.
      def get_char(tag : String) : Char?
        aux_ptr = get_aux_pointer(tag)
        return if aux_ptr.null?
        ensure_aux_type!(tag, aux_ptr, "character") { |type| type == AUX_CHAR_TYPE }

        LibHTS.bam_aux2_a(aux_ptr).chr
      end

      # Returns the integer array for *tag*, `nil` when absent, and raises
      # `AuxTypeError` when the tag exists with a non-integer-array type.
      def get_int_array(tag : String) : Array(Int64)?
        aux_ptr = get_aux_pointer(tag)
        return if aux_ptr.null?
        ensure_aux_type!(tag, aux_ptr, "integer array") { |type| type == AUX_ARRAY_TYPE }

        array_type = (aux_ptr + 1).value
        raise_aux_type_error!(tag, "integer array") unless AUX_INT_TYPES.includes?(array_type)

        length = LibHTS.bam_aux_b_len(aux_ptr)
        Array(Int64).new(length) { |i| LibHTS.bam_aux_b2i(aux_ptr, i) }
      end

      # Returns the float array for *tag*, `nil` when absent, and raises
      # `AuxTypeError` when the tag exists with a non-float-array type.
      def get_float_array(tag : String) : Array(Float64)?
        aux_ptr = get_aux_pointer(tag)
        return if aux_ptr.null?
        ensure_aux_type!(tag, aux_ptr, "float array") { |type| type == AUX_ARRAY_TYPE }
        raise_aux_type_error!(tag, "float array") unless (aux_ptr + 1).value == AUX_FLOAT_ARRAY_TYPE

        length = LibHTS.bam_aux_b_len(aux_ptr)
        Array(Float64).new(length) { |i| LibHTS.bam_aux_b2f(aux_ptr, i) }
      end

      def update_int(tag : String, value : Int)
        tag_array = Bam.aux_tag_to_static_array(tag)
        check_update_rc!(LibHTS.bam_aux_update_int(@bam1, tag_array, value.to_i64), tag)
        self
      end

      def update_float(tag : String, value : Number)
        tag_array = Bam.aux_tag_to_static_array(tag)
        check_update_rc!(LibHTS.bam_aux_update_float(@bam1, tag_array, value.to_f32), tag)
        self
      end

      def update_string(tag : String, value : String)
        tag_array = Bam.aux_tag_to_static_array(tag)
        check_update_rc!(LibHTS.bam_aux_update_str(@bam1, tag_array, value.bytesize + 1, value), tag)
        self
      end

      def update_array(tag : String, values : Array(Number), subtype : Char = 'i')
        tag_array = Bam.aux_tag_to_static_array(tag)

        case subtype
        when 'c'
          update_array_numeric(tag, tag_array, subtype, values) { |v| v.to_i8 }
        when 'C'
          update_array_numeric(tag, tag_array, subtype, values) { |v| v.to_u8 }
        when 's'
          update_array_numeric(tag, tag_array, subtype, values) { |v| v.to_i16 }
        when 'S'
          update_array_numeric(tag, tag_array, subtype, values) { |v| v.to_u16 }
        when 'i'
          update_array_numeric(tag, tag_array, subtype, values) { |v| v.to_i32 }
        when 'I'
          update_array_numeric(tag, tag_array, subtype, values) { |v| v.to_u32 }
        when 'f'
          update_array_numeric(tag, tag_array, subtype, values) { |v| v.to_f32 }
        else
          raise ArgumentError.new("Unsupported B array subtype: #{subtype}")
        end

        self
      rescue OverflowError
        raise ArgumentError.new("Value out of range for B array subtype #{subtype}")
      end

      def update_char(tag : String, value : Char)
        tag_array = Bam.aux_tag_to_static_array(tag)
        char_byte = value.ord
        raise ArgumentError.new("AUX A type expects single-byte ASCII character") if char_byte > 0x7f
        data = char_byte.to_u8
        replace_with_append!(tag, tag_array, 'A', 1, pointerof(data))
        self
      end

      def update_hex(tag : String, value : String)
        tag_array = Bam.aux_tag_to_static_array(tag)
        unless value.matches?(/\A[0-9A-Fa-f]*\z/) && value.bytesize.even?
          raise ArgumentError.new("AUX H type expects an even-length hexadecimal string")
        end
        hex = value.upcase
        replace_with_append!(tag, tag_array, 'H', hex.bytesize + 1, hex.to_unsafe)
        self
      end

      def update_double(tag : String, value : Number)
        tag_array = Bam.aux_tag_to_static_array(tag)
        data = value.to_f64
        replace_with_append!(tag, tag_array, 'd', 8, pointerof(data).as(UInt8*))
        self
      end

      def update_int8(tag : String, value : Int)
        tag_array = Bam.aux_tag_to_static_array(tag)
        data = value.to_i8
        replace_with_append!(tag, tag_array, 'c', 1, pointerof(data).as(UInt8*))
        self
      rescue OverflowError
        raise ArgumentError.new("Value out of range for int8")
      end

      def update_uint8(tag : String, value : Int)
        tag_array = Bam.aux_tag_to_static_array(tag)
        data = value.to_u8
        replace_with_append!(tag, tag_array, 'C', 1, pointerof(data).as(UInt8*))
        self
      rescue OverflowError
        raise ArgumentError.new("Value out of range for uint8")
      end

      def update_int16(tag : String, value : Int)
        tag_array = Bam.aux_tag_to_static_array(tag)
        data = value.to_i16
        replace_with_append!(tag, tag_array, 's', 2, pointerof(data).as(UInt8*))
        self
      rescue OverflowError
        raise ArgumentError.new("Value out of range for int16")
      end

      def update_uint16(tag : String, value : Int)
        tag_array = Bam.aux_tag_to_static_array(tag)
        data = value.to_u16
        replace_with_append!(tag, tag_array, 'S', 2, pointerof(data).as(UInt8*))
        self
      rescue OverflowError
        raise ArgumentError.new("Value out of range for uint16")
      end

      def update_int32(tag : String, value : Int)
        tag_array = Bam.aux_tag_to_static_array(tag)
        data = value.to_i32
        replace_with_append!(tag, tag_array, 'i', 4, pointerof(data).as(UInt8*))
        self
      rescue OverflowError
        raise ArgumentError.new("Value out of range for int32")
      end

      def update_uint32(tag : String, value : Int)
        tag_array = Bam.aux_tag_to_static_array(tag)
        data = value.to_u32
        replace_with_append!(tag, tag_array, 'I', 4, pointerof(data).as(UInt8*))
        self
      rescue OverflowError
        raise ArgumentError.new("Value out of range for uint32")
      end

      # Parse auxiliary value based on its type
      private def parse_aux_value(aux_ptr)
        return if aux_ptr.null?

        t = aux_ptr.value
        case t
        when 'i', 'I', 'c', 'C', 's', 'S'
          LibHTS.bam_aux2i(aux_ptr)
        when 'f', 'd'
          LibHTS.bam_aux2f(aux_ptr)
        when 'Z', 'H'
          String.new LibHTS.bam_aux2_z(aux_ptr)
        when 'A'
          LibHTS.bam_aux2_a(aux_ptr).chr
        when 'B'
          parse_aux_array(aux_ptr) # Basic array type support
        end
      rescue
        nil
      end

      # Parse auxiliary value with original type information preserved
      private def parse_aux_value_with_type(aux_ptr)
        return {nil, nil} if aux_ptr.null?

        original_type = aux_ptr.value.chr
        value = case aux_ptr.value
                when 'i', 'I', 'c', 'C', 's', 'S'
                  LibHTS.bam_aux2i(aux_ptr)
                when 'f', 'd'
                  LibHTS.bam_aux2f(aux_ptr)
                when 'Z', 'H'
                  String.new LibHTS.bam_aux2_z(aux_ptr)
                when 'A'
                  LibHTS.bam_aux2_a(aux_ptr).chr
                when 'B'
                  parse_aux_array(aux_ptr)
                end

        {value, original_type}
      rescue
        {nil, nil}
      end

      # Parse auxiliary array values
      private def parse_aux_array(aux_ptr)
        # Basic support for array types
        array_type = (aux_ptr + 1).value
        length = LibHTS.bam_aux_b_len(aux_ptr)

        case array_type
        when 'i', 'I', 'c', 'C', 's', 'S'
          Array.new(length) { |i| LibHTS.bam_aux_b2i(aux_ptr, i) }
        when 'f'
          Array.new(length) { |i| LibHTS.bam_aux_b2f(aux_ptr, i) }
        else
          "Array[#{array_type.chr}]:#{length}" # Unsupported array type - return descriptive string
        end
      rescue
        "Array[?]:0"
      end

      # Get pointer to auxiliary tag
      private def get_aux_pointer(tag)
        tag_array = Bam.aux_tag_to_static_array(tag)
        LibHTS.bam_aux_get(@bam1, tag_array)
      end

      private def check_update_rc!(rc : Int32, tag : String)
        raise "Failed to update AUX tag #{tag}" if rc < 0
      end

      private def ensure_aux_type!(tag : String, aux_ptr, expected_type : String, &)
        raise_aux_type_error!(tag, expected_type) unless yield aux_ptr.value
      end

      private def raise_aux_type_error!(tag : String, expected_type : String)
        raise AuxTypeError.new("AUX tag #{tag} is not #{expected_type}")
      end

      private def replace_with_append!(tag : String, tag_array : StaticArray(UInt8, 2), type : Char, len : Int32, data : Pointer(UInt8))
        existing = LibHTS.bam_aux_get(@bam1, tag_array)
        check_update_rc!(LibHTS.bam_aux_del(@bam1, existing), tag) unless existing.null?
        check_update_rc!(LibHTS.bam_aux_append(@bam1, tag_array, type.ord.to_u8, len, data), tag)
      end

      private def update_array_numeric(tag : String, tag_array : StaticArray(UInt8, 2), subtype : Char, values : Array(Number), &)
        converted = values.map { |value| yield value }
        items = converted.size.to_u32

        if converted.empty?
          empty = 0_u8
          check_update_rc!(LibHTS.bam_aux_update_array(@bam1, tag_array, subtype.ord.to_u8, items, pointerof(empty).as(Void*)), tag)
          return
        end

        check_update_rc!(LibHTS.bam_aux_update_array(@bam1, tag_array, subtype.ord.to_u8, items, converted.to_unsafe.as(Void*)), tag)
      end

      # HTSlib sam_format_aux1 compliant output with original type information
      def to_s(io : IO) : Nil
        aux_ptr = LibHTS.bam_aux_first(@bam1)
        flag = false
        while !aux_ptr.null?
          tag = String.new(aux_ptr - 2, 2)
          value, original_type = parse_aux_value_with_type(aux_ptr)

          if value && original_type
            io.print "\t" if flag
            io.print "#{tag}:#{format_aux_type(original_type, aux_ptr)}:#{format_aux_value(original_type, value)}"
            flag = true
          end

          aux_ptr = LibHTS.bam_aux_next(@bam1, aux_ptr)
        end
      end

      private def format_aux_type(original_type : Char, aux_ptr) : String
        case original_type
        when 'c', 'C', 's', 'S', 'i', 'I'
          "i"
        when 'f', 'd', 'A', 'Z', 'H'
          original_type.to_s
        when 'B'
          "B:#{(aux_ptr + 1).value.chr}"
        else
          "?"
        end
      end

      private def format_aux_value(original_type : Char, value) : String
        return value.join(",") if original_type == 'B' && value.is_a?(Array)

        value.to_s
      end
    end
  end
end
