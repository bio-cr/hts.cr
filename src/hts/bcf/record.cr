module HTS
  class Bcf
    class Record
      def initialize(bcf_t : Pointer(HTS::LibHTS::Bcf1T), header : Bcf::Header)
        @bcf1 = bcf_t
        @header = header
      end

      def struct
        @bcf1
      end

      getter :header

      def pos
        @bcf1.value.pos + 1
      end

      def start
        @bcf1.value.pos
      end

      def stop
        @bcf1.value.pos + @bcf1.value.rlen
      end

      def id
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_INFO)
        String.new(@bcf1.value.d.id)
      end

      def filter
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_FLT)
        d = @bcf1.value.d
        n_flt = d.n_flt

        case n_flt
        when 0
          "PASS"
        when 1
          i = d.flt.value
          String.new(LibHTS2.bcf_hdr_int2id(@header.struct, LibHTS2::BCF_DT_ID, i))
        when 2
          # FIXME note tested yet and may contain bugs
          StaticArray(String, 2).new do |i|
            j = d.flt[i]
            String.new(LibHTS2.bcf_hdr_int2id(@header.struct, LibHTS2::BCF_DT_ID, j))
          end
        else
          raise "unexpectd number of filters. n_flt: #{n_flt}"
        end
      end

      def qual
        @bcf1.value.qual
      end

      def ref
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_STR)
        String.new(@bcf1.value.d.allele[0])
      end

      def alt
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_STR)
        n = @bcf1.value.n_info_allele.bits(16..31)
        Array(String).new(n - 1) do |i|
          String.new(@bcf1.value.d.allele[i + 1])
        end
      end

      def alleles
        LibHTS.bcf_unpack(@bcf1, LibHTS2::BCF_UN_STR)
        n = @bcf1.value.n_info_allele.bits(16..31)
        Array(String).new(n) do |i|
          String.new(@bcf1.value.d.allele[i])
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

      def to_s
        ksr = LibHTS::KstringT.new
        raise "Failed to format record" if LibHTS.vcf_format(@header.struct, @bcf1, pointerof(ksr)) == -1

        String.new(ksr.s)
      end
    end
  end
end
