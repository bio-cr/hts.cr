require "../libhts"

module HTS
  class Bam < Hts
    # Base modification information from MM/ML tags
    # View over a Record's MM/ML tags using htslib base-mod API
    class BaseMod
      class Error < Exception; end

      # Individual base modification information
      class Modification
        getter modified_base : Int32
        getter canonical_base : Int32
        getter strand : Int32
        getter qual : Int32

        def initialize(@modified_base : Int32, @canonical_base : Int32, @strand : Int32, @qual : Int32)
        end

        # Single-letter code or negative ChEBI number as String
        def code : String
          if @modified_base > 0
            @modified_base.chr.to_s
          else
            @modified_base.to_s
          end
        end

        # Canonical base as single character string (A/C/G/T/N)
        def canonical : String
          @canonical_base.chr.to_s
        end

        # 0.0..1.0 probability, or nil if unknown (-1)
        def probability : Float64?
          return nil if @qual == -1
          @qual / 256.0
        end

        def to_s(io : IO) : String
          if (p = probability)
            io << "#{canonical}->#{code}(#{p.round(3)})"
          else
            io << "#{canonical}->#{code}"
          end
        end
      end

      # Position-specific modifications
      class Position
        getter position : Int32
        getter modifications : Array(Modification)

        def initialize(@position : Int32, @modifications : Array(Modification))
        end

        def methylated? : Bool
          @modifications.any? { |m| m.code == "m" }
        end

        def hydroxymethylated? : Bool
          @modifications.any? { |m| m.code == "h" }
        end

        def to_s : String
          mods_str = @modifications.map(&.to_s).join(", ")
          "pos=#{@position} [#{mods_str}]"
        end
      end

      # Enumerable over Position
      include Enumerable(Position)

      getter record : HTS::Bam::Record

      def initialize(@record : HTS::Bam::Record, @auto_parse : Bool = true)
        @state = LibHTS.hts_base_mod_state_alloc
        raise Error.new("Failed to allocate hts_base_mod_state") if @state.null?
        @closed = false
        @parsed = false
      end

      def close
        return if @closed
        LibHTS.hts_base_mod_state_free(@state) unless @state.null?
        @state = Pointer(Void).null
        @closed = true
      end

      def finalize
        close unless @closed
      end

      def parsed? : Bool
        @parsed
      end

      # Parse MM/ML tags; flags per HTSlib (e.g., HTS_MOD_REPORT_UNCHECKED = 1)
      def parse(flags : UInt32 = 0_u32) : Int32
        ret = LibHTS.bam_parse_basemod2(@record, @state, flags)
        raise Error.new("Failed to parse base modifications") if ret < 0
        @parsed = true
        ret
      end

      def ensure_parsed!(flags : UInt32 = 0_u32)
        return if @parsed
        raise Error.new("BaseMod is not parsed. Call parse first.") unless @auto_parse
        parse(flags)
      end

      # Get modifications at a specific query position (0-based); returns nil if none
      def at_pos(position : Int32, max_mods : Int32 = 10) : Position?
        ensure_parsed!

        mods_ptr = Pointer(LibHTS::HtsBaseMod).malloc(max_mods)
        begin
          ret = LibHTS.bam_mods_at_qpos(@record, position, @state, mods_ptr, max_mods)
          return nil if ret <= 0
          n = ret < max_mods ? ret : max_mods
          build_position(position, mods_ptr, n)
        ensure
          LibC.free(mods_ptr.as(Void*))
        end
      end

      # Iterate over all positions with modifications
      def each(max_mods : Int32 = 10, &block : Position ->)
        ensure_parsed!

        mods_ptr = Pointer(LibHTS::HtsBaseMod).malloc(max_mods)
        begin
          loop do
            ret = LibHTS.bam_next_basemod(@record, @state, mods_ptr, max_mods, out pos)
            break if ret <= 0
            n = ret < max_mods ? ret : max_mods
            yield build_position(pos, mods_ptr, n)
          end
        ensure
          LibC.free(mods_ptr.as(Void*))
        end
        self
      end

      # List of modification codes (positive char codes or negative ChEBI)
      def modification_types : Array(Int32)
        ensure_parsed!
        codes_ptr = LibHTS.bam_mods_recorded(@state, out ntype)
        return [] of Int32 if ntype <= 0 || codes_ptr.null?
        Array.new(ntype) { |i| codes_ptr[i] }
      end

      def recorded_types : Array(Int32)
        modification_types
      end

      # Query info about a specific modification code
      def query_type(code : Int32 | String)
        ensure_parsed!
        code_i = code.is_a?(String) ? code.ord : code
        ret = LibHTS.bam_mods_query_type(@state, code_i, out strand, out implicit, out canonical)
        return nil if ret < 0
        canonical = (canonical.to_u8).chr.to_s
        {canonical: canonical, strand: strand, implicit: implicit != 0}
      end

      # Query info about i-th modification type
      def query_type_at(index : Int32)
        ensure_parsed!
        ret = LibHTS.bam_mods_queryi(@state, index, out strand, out implicit, out canonical)
        return nil if ret < 0
        types = modification_types
        canonical = (canonical.to_u8).chr.to_s
        {code: types[index], canonical: canonical, strand: strand, implicit: implicit != 0}
      end

      def to_a : Array(Position)
        positions = [] of Position
        each { |pos| positions << pos }
        positions
      end

      def to_s : String
        return "#<HTS::Bam::BaseMod (not parsed)>" unless @parsed
        items = [] of String
        each { |pos| items << pos.to_s }
        "#<HTS::Bam::BaseMod #{items.join(' ')}>"
      end

      private def build_position(position : Int32, mods_ptr : Pointer(LibHTS::HtsBaseMod), n_mods : Int32) : Position
        modifications = Array(Modification).new(n_mods)
        i = 0
        while i < n_mods
          m = (mods_ptr + i).value
          modifications << Modification.new(m.modified_base, m.canonical_base, m.strand, m.qual)
          i += 1
        end
        Position.new(position, modifications)
      end
    end
  end
end
