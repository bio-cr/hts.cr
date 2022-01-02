module HTS
  class Bam
    class Flag
      def initialize(flag_value : UInt16)
        @value = flag_value
      end

      getter :value # FIXME: naming.

      # BAM_FPAIRED        =    1
      # BAM_FPROPER_PAIR   =    2
      # BAM_FUNMAP         =    4
      # BAM_FMUNMAP        =    8
      # BAM_FREVERSE       =   16
      # BAM_FMREVERSE      =   32
      # BAM_FREAD1         =   64
      # BAM_FREAD2         =  128
      # BAM_FSECONDARY     =  256
      # BAM_FQCFAIL        =  512
      # BAM_FDUP           = 1024
      # BAM_FSUPPLEMENTARY = 2048

      # TODO: Enabling bitwise operations
      # hts-nim
      # proc `and`*(f: Flag, o: uint16): uint16 {. borrow, inline .}
      # proc `and`*(f: Flag, o: Flag): uint16 {. borrow, inline .}
      # proc `or`*(f: Flag, o: uint16): uint16 {. borrow .}
      # proc `or`*(o: uint16, f: Flag): uint16 {. borrow .}
      # proc `==`*(f: Flag, o: Flag): bool {. borrow, inline .}
      # proc `==`*(f: Flag, o: uint16): bool {. borrow, inline .}
      # proc `==`*(o: uint16, f: Flag): bool {. borrow, inline .}

      def paired?
        has_flag? LibHTS2::BAM_FPAIRED
      end

      def proper_pair?
        has_flag? LibHTS2::BAM_FPROPER_PAIR
      end

      def unmapped?
        has_flag? LibHTS2::BAM_FUNMAP
      end

      def mate_unmapped?
        has_flag? LibHTS2::BAM_FMUNMAP
      end

      def reverse?
        has_flag? LibHTS2::BAM_FREVERSE
      end

      def mate_reverse?
        has_flag? LibHTS2::BAM_FMREVERSE
      end

      def read1?
        has_flag? LibHTS2::BAM_FREAD1
      end

      def read2?
        has_flag? LibHTS2::BAM_FREAD2
      end

      def secondary?
        has_flag? LibHTS2::BAM_FSECONDARY
      end

      def qcfail?
        has_flag? LibHTS2::BAM_FQCFAIL
      end

      def dup?
        has_flag? LibHTS2::BAM_FDUP
      end

      def supplementary?
        has_flag? LibHTS2::BAM_FSUPPLEMENTARY
      end

      def has_flag?(m)
        @value & m != 0
      end
      end
    end
  end
end
