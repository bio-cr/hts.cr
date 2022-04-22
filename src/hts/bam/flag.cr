module HTS
  class Bam < Hts
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

      TABLE = {paired?:        LibHTS2::BAM_FPAIRED,
               proper_pair?:   LibHTS2::BAM_FPROPER_PAIR,
               unmapped?:      LibHTS2::BAM_FUNMAP,
               mate_unmapped?: LibHTS2::BAM_FMUNMAP,
               reverse?:       LibHTS2::BAM_FREVERSE,
               mate_reverse?:  LibHTS2::BAM_FMREVERSE,
               read1?:         LibHTS2::BAM_FREAD1,
               read2?:         LibHTS2::BAM_FREAD2,
               secondary?:     LibHTS2::BAM_FSECONDARY,
               qcfail?:        LibHTS2::BAM_FQCFAIL,
               duplicate?:     LibHTS2::BAM_FDUP,
               supplementary?: LibHTS2::BAM_FSUPPLEMENTARY}

      {% for name, flg in TABLE %}
      def {{ name.id }}
        has_flag? {{ flg.id }}
      end
      {% end %}

      def has_flag?(m)
        @value & m != 0
      end

      def to_s(io : IO)
        io << String.new(LibHTS.bam_flag2str(@value))
        # io << "#{"0x%x" % @value}\t#{@value}\t#{String.new LibHTS.bam_flag2str(@value)}"
      end
    end
  end
end
