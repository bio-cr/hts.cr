require "../libhts"

module HTS
  class Bam < Hts
    # Base modification information from MM/ML tags
    # View over a Record's MM/ML tags using htslib base-mod API
    class BaseMod
      class Error < Bam::Error; end

      # Default flags for parsing base modifications via htslib
      # HTS_MOD_REPORT_UNCHECKED = 1 (report unvalidated mods instead of failing)
      HTS_MOD_REPORT_UNCHECKED = 1_u32

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
          return if @qual == -1
          @qual / 256.0
        end

        def to_s(io : IO) : Nil
          if p = probability
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
          @modifications.any? { |modification| modification.code == "m" }
        end

        def hydroxymethylated? : Bool
          @modifications.any? { |modification| modification.code == "h" }
        end

        def to_s(io : IO) : Nil
          mods_str = @modifications.map(&.to_s).join(", ")
          io << "pos=#{@position} [#{mods_str}]"
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
        # Reusable temporary buffer for LibHTS::HtsBaseMod structs
        @mods_buffer = Bytes.new(10 * sizeof(LibHTS::HtsBaseMod))
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
      # Default to reporting unchecked modifications so we see MM/ML content without strict validation.
      def parse(flags : UInt32 = HTS_MOD_REPORT_UNCHECKED) : Int32
        check_closed!
        ret = LibHTS.bam_parse_basemod2(@record, @state, flags)
        raise Error.new("Failed to parse base modifications") if ret < 0
        @parsed = true
        ret
      end

      def ensure_parsed!(flags : UInt32 = HTS_MOD_REPORT_UNCHECKED)
        check_closed!
        return if @parsed
        raise Error.new("BaseMod is not parsed. Call parse first.") unless @auto_parse
        parse(flags)
      end

      # Ensure a fresh iteration state: if already parsed, re-parse to reset
      private def reparse_or_parse!(flags : UInt32 = HTS_MOD_REPORT_UNCHECKED)
        if @parsed
          parse(flags)
        else
          ensure_parsed!(flags)
        end
      end

      # Get modifications at a specific query position (0-based); returns nil if none
      def at_pos(position : Int32, max_mods : Int32 = 10) : Position?
        check_closed!
        reparse_or_parse!

        ensure_buffer_capacity(max_mods)
        mods_ptr = @mods_buffer.to_unsafe.as(Pointer(LibHTS::HtsBaseMod))
        ret = LibHTS.bam_mods_at_qpos(@record, position, @state, mods_ptr, max_mods)
        return if ret <= 0
        # If the buffer was too small, re-fetch with the exact needed size to avoid truncation
        if ret > max_mods
          return fetch_position_from_fresh_state(position, ret)
        end
        build_position(position, mods_ptr, ret)
      end

      # Iterate over all positions with modifications
      def each(max_mods : Int32 = 10, & : Position ->)
        check_closed!
        reparse_or_parse!

        ensure_buffer_capacity(max_mods)
        mods_ptr = @mods_buffer.to_unsafe.as(Pointer(LibHTS::HtsBaseMod))
        loop do
          ret = LibHTS.bam_next_basemod(@record, @state, mods_ptr, max_mods, out pos)
          break if ret <= 0
          # If more mods exist than the buffer size, fetch the full set for this position
          if ret > max_mods
            yield fetch_position_from_fresh_state(pos, ret)
          else
            yield build_position(pos, mods_ptr, ret)
          end
        end
        self
      end

      # Alias for clarity and parity with common terminology
      def each_position(max_mods : Int32 = 10, &block : Position ->)
        each(max_mods, &block)
      end

      # Array-style access to modifications at a query position
      def [](position : Int32) : Position?
        at_pos(position)
      end

      # List of modification codes (positive char codes or negative ChEBI)
      def modification_types : Array(Int32)
        check_closed!
        ensure_parsed!
        codes_ptr = LibHTS.bam_mods_recorded(@state, out ntype)
        return [] of Int32 if ntype <= 0 || codes_ptr.null?
        Array.new(ntype) { |i| codes_ptr[i] }
      end

      # Alias for `modification_types`
      def recorded_types : Array(Int32)
        modification_types
      end

      # Query info about a specific modification code
      def query_type(code : Int32)
        check_closed!
        ensure_parsed!
        # canonical is written via char*; allocate a single byte buffer
        canonical_ch = uninitialized LibC::Char
        ret = LibHTS.bam_mods_query_type(@state, code, out strand, out implicit, pointerof(canonical_ch))
        return if ret < 0
        canonical = (canonical_ch.to_u8).chr.to_s
        {canonical: canonical, strand: strand, implicit: implicit != 0}
      end

      def query_type(code : Char)
        query_type(code.ord)
      end

      def query_type(code : String)
        raise ArgumentError.new("modification code string must contain exactly one character") unless code.size == 1

        query_type(code[0])
      end

      # Query info about i-th modification type
      def query_type_at(index : Int32)
        ensure_parsed!
        canonical_ch = uninitialized LibC::Char
        ret = LibHTS.bam_mods_queryi(@state, index, out strand, out implicit, pointerof(canonical_ch))
        return if ret < 0
        types = modification_types
        canonical = (canonical_ch.to_u8).chr.to_s
        {code: types[index], canonical: canonical, strand: strand, implicit: implicit != 0}
      end

      def to_a : Array(Position)
        positions = [] of Position
        each { |pos| positions << pos }
        positions
      end

      def to_s(io : IO) : Nil
        return "#<HTS::Bam::BaseMod (not parsed)>" unless @parsed
        items = [] of String
        each { |pos| items << pos.to_s }
        io << "#<HTS::Bam::BaseMod #{items.join(' ')}>"
      end

      private def check_closed!
        raise Error.new("BaseMod is closed") if @closed
      end

      private def build_position(position : Int32, mods_ptr : Pointer(LibHTS::HtsBaseMod), n_mods : Int32) : Position
        modifications = Array.new(n_mods) do |i|
          m = (mods_ptr + i).value
          Modification.new(m.modified_base, m.canonical_base, m.strand, m.qual)
        end
        Position.new(position, modifications)
      end

      private def fetch_position_from_fresh_state(position : Int32, max_mods : Int32) : Position
        state = LibHTS.hts_base_mod_state_alloc
        raise Error.new("Failed to allocate hts_base_mod_state") if state.null?

        begin
          ret = LibHTS.bam_parse_basemod2(@record, state, HTS_MOD_REPORT_UNCHECKED)
          raise Error.new("Failed to parse base modifications") if ret < 0

          ensure_buffer_capacity(max_mods)
          mods_ptr = @mods_buffer.to_unsafe.as(Pointer(LibHTS::HtsBaseMod))
          ret = LibHTS.bam_mods_at_qpos(@record, position, state, mods_ptr, max_mods)
          raise Error.new("Failed to read base modifications at query position #{position}") if ret < 0

          if ret > max_mods
            return fetch_position_from_fresh_state(position, ret)
          end

          build_position(position, mods_ptr, ret)
        ensure
          LibHTS.hts_base_mod_state_free(state) unless state.null?
        end
      end

      # Ensure the reusable buffer has at least `max_mods` capacity
      private def ensure_buffer_capacity(max_mods : Int32)
        needed = max_mods * sizeof(LibHTS::HtsBaseMod)
        if @mods_buffer.size < needed
          # grow by 1.5x to reduce realloc frequency
          new_size = Math.max(needed, (@mods_buffer.size * 3) // 2)
          @mods_buffer = Bytes.new(new_size)
        end
      end
    end
  end
end
