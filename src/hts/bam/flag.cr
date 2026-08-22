module HTS
  class Bam < Hts
    class Flag
      def initialize(flag_value : UInt16)
        @value = flag_value
      end

      getter :value

      # Named FLAG bit constants, as Flag values so they compose with `|`.
      # e.g. Bam::Flag::UNMAP | Bam::Flag::SECONDARY | Bam::Flag::DUP
      NONE          = new(0_u16)
      PAIRED        = new(LibHTS2::BAM_FPAIRED.to_u16)
      PROPER_PAIR   = new(LibHTS2::BAM_FPROPER_PAIR.to_u16)
      UNMAP         = new(LibHTS2::BAM_FUNMAP.to_u16)
      MUNMAP        = new(LibHTS2::BAM_FMUNMAP.to_u16)
      REVERSE       = new(LibHTS2::BAM_FREVERSE.to_u16)
      MREVERSE      = new(LibHTS2::BAM_FMREVERSE.to_u16)
      READ1         = new(LibHTS2::BAM_FREAD1.to_u16)
      READ2         = new(LibHTS2::BAM_FREAD2.to_u16)
      SECONDARY     = new(LibHTS2::BAM_FSECONDARY.to_u16)
      QCFAIL        = new(LibHTS2::BAM_FQCFAIL.to_u16)
      DUP           = new(LibHTS2::BAM_FDUP.to_u16)
      SUPPLEMENTARY = new(LibHTS2::BAM_FSUPPLEMENTARY.to_u16)

      UNMAPPED      = UNMAP
      MATE_UNMAPPED = MUNMAP
      DUPLICATE     = DUP

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
        (@value & m) != 0
      end

      def &(other)
        self.class.new(@value & other.to_i)
      end

      def |(other)
        self.class.new(@value | other.to_i)
      end

      def ^(other)
        self.class.new(@value ^ other.to_i)
      end

      def ~
        # All bits are flipped.
        # But only the lower 12 bits are used for FLAG values.
        # According to the SAM specification,
        # > reserved FLAG bits should be written as zero and ignored on reading by current software.
        # Perhaps, we should ignore the upper 4 bits.
        self.class.new((~@value) & 0x0fff_u16)
      end

      def <<(other)
        self.class.new(@value << other.to_i)
      end

      def >>(other)
        self.class.new(@value >> other.to_i)
      end

      def to_i
        @value
      end

      def to_s(io : IO)
        io << String.new(LibHTS.bam_flag2str(@value))
        # io << "#{"0x%x" % @value}\t#{@value}\t#{String.new LibHTS.bam_flag2str(@value)}"
      end
    end
  end
end
