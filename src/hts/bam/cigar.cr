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

      def each
        @c.each do |c|
          op = LibHTS2.bam_cigar_opchr(c)
          len = LibHTS2.bam_cigar_oplen(c)
          yield({op, len})
        end
      end
    end
  end
end
