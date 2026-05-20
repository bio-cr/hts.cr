module HTS
  class Bam < Hts
    class Cigar
      include Enumerable(Tuple(Char, UInt32))

      def initialize(pointer : Pointer(UInt32), n_cigar : UInt32)
        # Read the pointer before the memory is changed.
        @n_cigar = n_cigar
        @c = Array(UInt32).new(n_cigar) do |i|
          pointer[i]
        end
      end

      # Convenience: build from a CIGAR string like "10M1I5M"
      def initialize(cigar_str : String)
        @c = self.class.encode(cigar_str)
        @n_cigar = @c.size.to_u32
      end

      # Convenience: build from op tuples, e.g., [{'M', 10_u32}, {'I', 1_u32}]
      def initialize(ops : Array(Tuple(Char, UInt32)))
        @c = self.class.encode(ops)
        @n_cigar = @c.size.to_u32
      end

      def to_s(io : IO)
        each do |op, len|
          io << len
          io << op
        end
      end

      def each(&)
        @c.each do |cigar_op|
          op = LibHTS2.bam_cigar_opchr(cigar_op)
          len = LibHTS2.bam_cigar_oplen(cigar_op)
          yield({op, len})
        end
      end

      # Encode helpers
      #
      # Supported op chars follow htslib: M I D N S H P = X B
      # Returns an Array of UInt32 where each element packs len/op as in BAM.
      def self.encode(ops : Array(Tuple(Char, UInt32))) : Array(UInt32)
        Array(UInt32).new(ops.size) do |i|
          op_char, len = ops[i]
          (len << 4) | op_code(op_char)
        end
      end

      # Parse a CIGAR string like "10M1I5M" into encoded UInt32 words.
      def self.encode(cigar_str : String) : Array(UInt32)
        res = [] of UInt32
        num = 0_u32
        cigar_str.each_char do |char|
          if char.ascii_number?
            # keep calculations in UInt32 domain to avoid unions
            num = num * 10_u32 + (char.ord - '0'.ord).to_u32
          else
            raise ArgumentError.new("Invalid CIGAR: length missing before '#{char}'") if num == 0
            code = op_code(char)
            res << ((num << 4) | code).to_u32
            num = 0
          end
        end
        raise ArgumentError.new("Invalid CIGAR: trailing length without op") unless num == 0
        res
      end

      # Map CIGAR op char -> op code (htslib BAM op codes)
      private def self.op_code(ch : Char) : UInt32
        case ch
        when 'M' then 0_u32
        when 'I' then 1_u32
        when 'D' then 2_u32
        when 'N' then 3_u32
        when 'S' then 4_u32
        when 'H' then 5_u32
        when 'P' then 6_u32
        when '=' then 7_u32
        when 'X' then 8_u32
        when 'B' then 9_u32
        else
          raise ArgumentError.new("Unknown CIGAR op: #{ch}")
        end
      end
    end
  end
end
