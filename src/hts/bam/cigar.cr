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

      def to_s(io : IO)
        each do |op, len|
          io << len
          io << op
        end
      end

      def each(&)
        @c.each do |c|
          op = LibHTS2.bam_cigar_opchr(c)
          len = LibHTS2.bam_cigar_oplen(c)
          yield({op, len})
        end
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
