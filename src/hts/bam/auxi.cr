# This file is named auxi.cr because aux.cr causes issues on Windows.

module HTS
  class Bam < Hts
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
    #   # Access specific tag
    #   as_score = record.aux["AS"]
    class Aux
      # include Enumerable # DO NOT

      def initialize(@bam1 : Pointer(LibHTS::Bam1T))
      end

      # Iterate over all auxiliary tags
      def each(&block)
        aux_ptr = LibHTS.bam_aux_first(@bam1)
        while !aux_ptr.null?
          tag = String.new(aux_ptr - 2, 2)
          value = parse_aux_value(aux_ptr)
          yield tag, value
          aux_ptr = LibHTS.bam_aux_next(@bam1, aux_ptr)
        end
      end

      # Array-style access to specific tags
      def [](tag : String)
        get_aux_value(tag)
      end

      # Type-specific access methods
      def get_int(tag : String)
        aux_ptr = get_aux_pointer(tag)
        return nil if aux_ptr.null?
        LibHTS.bam_aux2i(aux_ptr)
      end

      def get_float(tag : String)
        aux_ptr = get_aux_pointer(tag)
        return nil if aux_ptr.null?
        LibHTS.bam_aux2f(aux_ptr)
      end

      def get_string(tag : String)
        aux_ptr = get_aux_pointer(tag)
        return nil if aux_ptr.null?
        String.new LibHTS.bam_aux2_z(aux_ptr)
      end

      # Parse auxiliary value based on its type
      private def parse_aux_value(aux_ptr)
        return nil if aux_ptr.null?

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
        else
          nil # Return nil for unknown types to allow continuation
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
                else
                  nil
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
        b = tag.bytes
        tag_array = StaticArray(UInt8, 2).new { |i| b[i] }
        LibHTS.bam_aux_get(@bam1, tag_array)
      end

      # Get auxiliary value for specific tag
      private def get_aux_value(tag)
        aux_ptr = get_aux_pointer(tag)
        return nil if aux_ptr.null?
        parse_aux_value(aux_ptr)
      end

      # HTSlib sam_format_aux1 compliant output with original type information
      def to_s(io : IO) : Nil
        aux_ptr = LibHTS.bam_aux_first(@bam1)
        flag = false
        while !aux_ptr.null?
          tag = String.new(aux_ptr - 2, 2)
          value, original_type = parse_aux_value_with_type(aux_ptr)

          if value && original_type
            # HTSlib sam_format_aux1 compliant type mapping
            type_str = case original_type
                       when 'c', 'C', 's', 'S', 'i', 'I' then "i" # All integer types output as "i:"
                       when 'f'                          then "f"
                       when 'd'                          then "d" # Non-standard but supported
                       when 'A'                          then "A"
                       when 'Z'                          then "Z"
                       when 'H'                          then "H"
                       when 'B'                          then "B:#{(aux_ptr + 1).value.chr}" # Array type with element type
                       else                                   "?"
                       end

            # Format value according to type
            formatted_value = case original_type
                              when 'B' then value.is_a?(Array) ? value.join(",") : value.to_s # Array formatting
                              else          value.to_s
                              end

            io.print "\t" if flag
            io.print "#{tag}:#{type_str}:#{formatted_value}"
            flag = true
          end

          aux_ptr = LibHTS.bam_aux_next(@bam1, aux_ptr)
        end
      end
    end
  end
end
