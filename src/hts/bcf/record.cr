module HTS
  class Bcf < Hts
    class Record
      @info : Info?
      @format : Format?

      # Shared native storage keeps accessor wrappers valid without retaining
      # the Record object and creating a finalizer cycle.
      # :nodoc:
      class Storage
        getter pointer : Pointer(LibHTS::Bcf1T)
        getter scratch : Scratch

        def initialize(@pointer : Pointer(LibHTS::Bcf1T))
          @scratch = Scratch.new
        end

        def finalize
          @scratch.close
          LibHTS.bcf_destroy(@pointer) unless @pointer.null?
        end
      end

      # :nodoc:
      struct AccessorContext
        getter :header

        def initialize(@header : Bcf::Header, @storage : Storage)
        end

        def scratch : Scratch
          @storage.scratch
        end

        def to_unsafe : Pointer(LibHTS::Bcf1T)
          @storage.pointer
        end
      end

      def initialize(header : Bcf::Header, bcf_t : Pointer(HTS::LibHTS::Bcf1T))
        @header = header
        @bcf1 = bcf_t
        @storage = Storage.new(@bcf1)
        @accessor_context = AccessorContext.new(@header, @storage)
      end

      def initialize(header : Bcf::Header)
        @header = header
        @bcf1 = new_bcf1!
        @storage = Storage.new(@bcf1)
        @accessor_context = AccessorContext.new(@header, @storage)
      end

      getter :header

      # Internal reusable storage for HTSlib getter results.
      # :nodoc:
      def scratch : Scratch
        @storage.scratch
      end

      # :nodoc:
      def accessor_context : AccessorContext
        @accessor_context
      end

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
        record_rid = rid
        count = @header.target_count
        unless 0 <= record_rid < count
          raise RecordError.new("Record rid #{record_rid} is outside header targets 0...#{count}")
        end

        name = LibHTS2.bcf_hdr_id2name(@header, record_rid)
        raise RecordError.new("Missing chromosome name for record rid #{record_rid}") if name.null?
        String.new(name)
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
        unpack!(LibHTS2::BCF_UN_INFO)
        String.new @bcf1.value.d.id
      end

      def id=(id : String)
        update_id!(id)
      end

      def clear_id
        update_id!(".")
      end

      def filters : Array(String)
        count = filter_count
        return ["PASS"] if count == 0

        names = Array(String).new(count)
        each_filter_id do |id|
          id_count = @header.to_unsafe.value.n[LibHTS2::BCF_DT_ID]
          unless 0 <= id < id_count
            raise RecordError.new("Unknown FILTER id #{id} in record")
          end
          name = LibHTS2.bcf_hdr_int2id(@header, LibHTS2::BCF_DT_ID, id)
          raise RecordError.new("Unknown FILTER id #{id} in record") if name.null?
          names << String.new(name)
        end
        names
      end

      @[Experimental]
      def filter_count : Int32
        unpack!(LibHTS2::BCF_UN_FLT)
        @bcf1.value.d.n_flt
      end

      @[Experimental]
      def filter_id_at(index : Int) : Int32
        count = filter_count
        unless 0 <= index < count
          raise ::IndexError.new("filter index #{index} out of range 0...#{count}")
        end
        @bcf1.value.d.flt[index]
      end

      @[Experimental]
      def each_filter_id(& : Int32 ->) : Nil
        count = filter_count
        filter_ids = @bcf1.value.d.flt
        count.times { |index| yield filter_ids[index] }
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
        unpack!(LibHTS2::BCF_UN_STR)
        String.new @bcf1.value.d.allele[0]
      end

      def alt
        alleles = Array(String).new(allele_count - 1)
        allele_index = 0
        each_allele_view do |allele|
          alleles << String.new(allele) if allele_index > 0
          allele_index += 1
        end
        alleles
      end

      def alleles
        alleles = Array(String).new(allele_count)
        each_allele_view do |allele|
          alleles << String.new(allele)
        end
        alleles
      end

      @[Experimental]
      def allele_count : Int32
        # htslib exposes n_allele as a C bitfield. Crystal cannot bind C
        # bitfields directly, so the binding stores n_info/n_allele packed.
        @bcf1.value.n_info_allele.bits(16..31).to_i32
      end

      @[Experimental]
      def each_allele_view(& : Bytes ->) : Nil
        unpack!(LibHTS2::BCF_UN_STR)
        allele_pointers = @bcf1.value.d.allele
        allele_count.times do |index|
          allele = allele_pointers[index]
          yield Bytes.new(allele.as(UInt8*), LibC.strlen(allele).to_i)
        end
      end

      def info
        unpack!(LibHTS2::BCF_UN_SHR)
        @info ||= Info.new(@accessor_context)
      end

      def format
        unpack!(LibHTS2::BCF_UN_FMT)
        @format ||= Format.new(@accessor_context)
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

      private def unpack!(which : Int32) : Nil
        rc = LibHTS.bcf_unpack(@bcf1, which)
        raise RecordError.new("Failed to unpack BCF record (rc=#{rc})") if rc < 0
      end

      private def update_id!(id : String) : String
        raise RecordUpdateError.new("BCF record ID must not contain a NUL byte") if id.includes?('\0')

        rc = LibHTS.bcf_update_id(@header, @bcf1, id)
        raise RecordUpdateError.new("Failed to update BCF record ID (rc=#{rc})") if rc < 0
        id
      end
    end
  end
end
