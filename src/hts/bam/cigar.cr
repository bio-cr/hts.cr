module HTS
  class Bam < Hts
    class Cigar
      include Enumerable(Tuple(Char, UInt32))

      def initialize(pointer : Pointer(UInt32), n_cigar : UInt32)
        @pointer = pointer
        @n_cigar = n_cigar
      end

      def to_ptr
        @pointer
      end

      def to_s(io : IO)
        each do |op, len|
          io << len
          io << op
        end
      end

      def each
        @n_cigar.times do |i|
          c = @pointer[i]
          op  = LibHTS2.bam_cigar_opchr(c) 
          len = LibHTS2.bam_cigar_oplen(c)
          yield({op, len})
        end
      end
    end
  end
end
