module HTS
  class Bcf < Hts
    class Record
      def initialize(header : Bcf::Header, bcf_t : Pointer(HTS::LibHTS::Bcf1T))
        @header = header
        @bcf1 = bcf_t
        @scratch = Scratch.new
      end

      def initialize(header : Bcf::Header)
        @header = header
        @bcf1 = new_bcf1!
        @scratch = Scratch.new
      end

      getter :header

      # Internal reusable storage for HTSlib getter results.
      # :nodoc:
      getter :scratch

      def to_unsafe
        @bcf1
      end

      private def new_bcf1! : LibHTS::Bcf1T*
        bcf1 = LibHTS.bcf_init
        raise RecordError.new("bcf_init failed") if bcf1.null?
        bcf1
      end

      def rid
        @bcf1.value.rid
      end

      def rid=(rid)
        @bcf1.value.rid = rid
      end

      def chrom
        String.new LibHTS2.bcf_hdr_id2name(@header, rid)
      end

      def pos
        @bcf1.value.pos
      end

      def pos=(pos)
        @bcf1.value.pos = pos
      end

      def endpos
        pos + @bcf1.value.rlen
      end

      def id
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_INFO)
        String.new @bcf1.value.d.id
      end

      def id=(id)
        LibHTS.bcf_update_id(@header, @bcf1, id)
      end

      def clear_id
        LibHTS.bcf_update_id(@header, @bcf1, ".")
      end

      def filters : Array(String)
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_FLT)
        d = @bcf1.value.d
        n_flt = d.n_flt

        case n_flt
        when 0
          ["PASS"]
        when 1
          i = d.flt.value
          [String.new LibHTS2.bcf_hdr_int2id(@header, LibHTS2::BCF_DT_ID, i)]
        when 2..
          Array(String).new(n_flt) do |index|
            j = d.flt[index]
            String.new LibHTS2.bcf_hdr_int2id(@header, LibHTS2::BCF_DT_ID, j)
          end
        else
          raise RecordError.new("Unexpected number of filters. n_flt: #{n_flt}")
        end
      end

      # VCF FILTER can contain multiple values, so keep the return type stable.
      def filter : Array(String)
        filters
      end

      def qual
        @bcf1.value.qual
      end

      def qual=(qual)
        @bcf1.value.qual = qual
      end

      def ref
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_STR)
        String.new @bcf1.value.d.allele[0]
      end

      def alt
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_STR)
        n = n_allele
        Array(String).new(n - 1) do |i|
          String.new @bcf1.value.d.allele[i + 1]
        end
      end

      def alleles
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_STR)
        n = n_allele
        Array(String).new(n) do |i|
          String.new @bcf1.value.d.allele[i]
        end
      end

      def info
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_SHR)
        Info.new(self)
      end

      def format
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_FMT)
        Format.new(self)
      end

      def to_s(io : IO)
        ksr = LibHTS::KstringT.new
        ksr.l = 0
        ksr.m = 0
        ksr.s = Pointer(LibC::Char).null

        begin
          raise RecordError.new("Failed to format record") if LibHTS.vcf_format(@header, @bcf1, pointerof(ksr)) == -1

          io << (String.new ksr.s)
        ensure
          LibC.free(ksr.s) unless ksr.s.null?
        end
      end

      def clone
        # Duplicate bcf1 and use reference for header.
        bcf1 = LibHTS.bcf_dup(@bcf1)
        raise RecordError.new("bcf_dup failed") if bcf1.null?

        self.class.new(@header, bcf1)
      end

      # garbage collection
      def finalize
        @scratch.close
        LibHTS.bcf_destroy(@bcf1) unless @bcf1.null?
      end

      private def n_allele : Int32
        # htslib exposes n_allele as a C bitfield. Crystal cannot bind C
        # bitfields directly, so the binding stores n_info/n_allele packed.
        @bcf1.value.n_info_allele.bits(16..31).to_i32
      end
    end
  end
end
