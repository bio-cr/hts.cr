require "./bam"

module HTS
  class Pileup
    # Represents a single alignment in the pileup (borrowed view)
    # WARNING: This object is only valid until the next next() call.
    # Do not store it outside the iteration block. Copy values if needed.
    struct Alignment
      @ptr : LibHTS::BamPileup1T*
      @header : Bam::Header
      
      protected def initialize(@ptr : LibHTS::BamPileup1T*, @header : Bam::Header)
      end
      
      # Query position (0-based)
      def qpos : Int32
        @ptr.value.qpos
      end
      
      # Indel length (0=none, positive=ins, negative=del)
      def indel : Int32
        @ptr.value.indel
      end
      
      # Level in viewer mode
      def level : Int32
        @ptr.value.level
      end
      
      # Is this position a deletion?
      def is_del : Bool
        (@ptr.value.bitfields & 0x1) != 0
      end
      
      # Is this the first base in the query?
      def is_head : Bool
        (@ptr.value.bitfields & 0x2) != 0
      end
      
      # Is this the last base in the query?
      def is_tail : Bool
        (@ptr.value.bitfields & 0x4) != 0
      end
      
      # Is this base part of a reference skip (N in CIGAR)?
      def is_refskip : Bool
        (@ptr.value.bitfields & 0x8) != 0
      end
      
      # Get base character (nil if del/refskip)
      def base? : Char?
        return nil if is_del || is_refskip
        seq = LibHTS2.bam_get_seq(@ptr.value.b)
        Bam::Record::SEQ_NT16_STR[LibHTS2.bam_seqi(seq, qpos)]
      end
      
      # Get base quality (0 if del/refskip)
      def base_quality : UInt8
        return 0_u8 if is_del || is_refskip
        qual = LibHTS2.bam_get_qual(@ptr.value.b)
        qual[qpos]
      end
      
      # CIGAR operation index
      def cigar_index : Int32
        @ptr.value.cigar_ind
      end
      
      # Get borrowed BAM record (WARNING: do not call bam_destroy1)
      def record : Bam::Record
        Bam::Record.borrowed(@header, @ptr.value.b)
      end
      
      # Create a safe copy of the BAM record
      def dup_record : Bam::Record
        Bam::Record.dup(@header, @ptr.value.b)
      end
      
      # Get internal pointer (for Helper functions)
      protected def to_unsafe : LibHTS::BamPileup1T*
        @ptr
      end
    end
    
    # Context for reader callback
    private struct ReaderContext
      getter bam : Bam
      getter header : Bam::Header
      getter reader : Proc(Bam, Bam::Header, Bam::Record, Int32)
      
      def initialize(@bam, @header, @reader)
      end
    end
    
    # Single BAM file pileup iterator
    class Iterator
      include Enumerable({Int32, Int64, Array(Alignment)})
      
      @plp : LibHTS::BamPlpT
      @context : ReaderContext
      @box : Void*
      @closed : Bool = false
      
      # Create iterator with custom reader function
      # reader: Function that reads next record. Returns >0 on success, 0 on EOF, <0 on error
      def initialize(bam : Bam, &@reader : (Bam, Bam::Header, Bam::Record) -> Int32)
        @context = ReaderContext.new(bam, bam.header, @reader)
        @box = Box.box(@context)
        @plp = LibHTS.bam_plp_init(->Iterator.c_reader_stub, @box)
        raise "Failed to initialize pileup iterator" if @plp.null?
      end
      
      # Create iterator with filter function
      # filter: Returns true to accept record, false to skip
      def self.with_filter(bam : Bam, &filter : Bam::Record -> Bool) : Iterator
        reader = ->(b : Bam, h : Bam::Header, rec : Bam::Record) {
          loop do
            ret = b.read1(h, rec.to_unsafe)
            return ret if ret <= 0  # EOF or error
            
            # Check filter
            if filter.call(rec)
              return ret  # accept
            end
            # reject, read next
          end
          0  # unreachable
        }
        
        new(bam, &reader)
      end
      
      # RAII style opener
      def self.open(bam : Bam, &filter : Bam::Record -> Bool)
        iter = with_filter(bam, &filter)
        begin
          yield iter
        ensure
          iter.close
        end
      end
      
      # C callback stub
      @[Extern]
      private def self.c_reader_stub(userdata : Void*, b : LibHTS::Bam1T*) : Int32
        context = Box(ReaderContext).unbox(userdata)
        rec = Bam::Record.borrowed(context.header, b)
        context.reader.call(context.bam, context.header, rec)
      end
      
      # Get next pileup column (returns nil on EOF)
      # Returns: {tid, pos (0-based), alignments} or nil
      def next : {Int32, Int64, Array(Alignment)}?
        return nil if @closed
        
        tid = uninitialized Int32
        pos = uninitialized Int64
        n_plp = uninitialized Int32
        
        plp_ptr = LibHTS.bam_plp64_next(@plp, pointerof(tid), pointerof(pos), pointerof(n_plp))
        
        return nil if plp_ptr.null?
        
        alignments = Array(Alignment).new(n_plp) do |i|
          Alignment.new(plp_ptr + i, @context.header)
        end
        
        {tid, pos, alignments}
      end
      
      # Iterate over all pileup columns
      def each(&block : {Int32, Int64, Array(Alignment)} ->)
        while result = self.next
          yield result
        end
      end
      
      # Set maximum depth per file
      def max_depth=(depth : Int32)
        LibHTS.bam_plp_set_maxcnt(@plp, depth)
      end
      
      # Reset iterator to beginning
      def reset
        LibHTS.bam_plp_reset(@plp)
      end
      
      # Close the iterator
      def close
        return if @closed
        LibHTS.bam_plp_destroy(@plp) unless @plp.null?
        @closed = true
      end
      
      def finalize
        close unless @closed
      end
    end
    
    # Multi-BAM file pileup iterator
    class MultiIterator
      include Enumerable({Int32, Int64, Array(Array(Alignment))})
      
      @mplp : LibHTS::BamMplpT
      @contexts : Array(ReaderContext)
      @boxes : Array(Void*)
      @n_bams : Int32
      @closed : Bool = false
      @overlap_detection_enabled : Bool = false
      
      # Create multi-iterator with custom reader functions
      def initialize(bams : Array(Bam), readers : Array(Proc(Bam, Bam::Header, Bam::Record, Int32)))
        raise ArgumentError.new("Number of BAMs and readers must match") if bams.size != readers.size
        
        @n_bams = bams.size
        @contexts = Array(ReaderContext).new(@n_bams) do |i|
          ReaderContext.new(bams[i], bams[i].header, readers[i])
        end
        
        @boxes = @contexts.map { |ctx| Box.box(ctx) }
        
        data_ptr = @boxes.to_unsafe.as(Void**)
        @mplp = LibHTS.bam_mplp_init(@n_bams, ->MultiIterator.c_reader_stub, data_ptr)
        raise "Failed to initialize multi-pileup iterator" if @mplp.null?
      end
      
      # Create multi-iterator with common filter for all BAMs
      def self.with_filter(bams : Array(Bam), &filter : Bam::Record -> Bool) : MultiIterator
        readers = Array.new(bams.size) do |i|
          bam = bams[i]
          ->(b : Bam, h : Bam::Header, rec : Bam::Record) {
            loop do
              ret = b.read1(h, rec.to_unsafe)
              return ret if ret <= 0
              
              if filter.call(rec)
                return ret
              end
            end
            0
          }
        end
        
        new(bams, readers)
      end
      
      # RAII style opener
      def self.open(bams : Array(Bam), &filter : Bam::Record -> Bool)
        iter = with_filter(bams, &filter)
        begin
          yield iter
        ensure
          iter.close
        end
      end
      
      # C callback stub
      @[Extern]
      private def self.c_reader_stub(userdata : Void*, b : LibHTS::Bam1T*) : Int32
        context = Box(ReaderContext).unbox(userdata)
        rec = Bam::Record.borrowed(context.header, b)
        context.reader.call(context.bam, context.header, rec)
      end
      
      # Get next pileup column for all samples
      # Returns: {tid, pos (0-based), samples} or nil
      # samples[i] contains alignments for the i-th BAM file
      def next : {Int32, Int64, Array(Array(Alignment))}?
        return nil if @closed
        
        tid = uninitialized Int32
        pos = uninitialized Int64
        n_plp = Pointer(Int32).malloc(@n_bams)
        plp = Pointer(LibHTS::BamPileup1T*).malloc(@n_bams)
        
        ret = LibHTS.bam_mplp64_auto(@mplp, pointerof(tid), pointerof(pos), n_plp, pointerof(plp))
        
        return nil if ret <= 0
        
        begin
          samples = Array(Array(Alignment)).new(@n_bams) do |i|
            count = n_plp[i]
            plp_ptr = plp[i]

            Array(Alignment).new(count) do |j|
              Alignment.new(plp_ptr + j, @contexts[i].header)
            end
          end

          {tid, pos, samples}
        ensure
          # Free temporary arrays allocated for this call
          LibC.free(n_plp.as(Void*)) unless n_plp.null?
          LibC.free(plp.as(Void*)) unless plp.null?
        end
      end
      
      # Iterate over all pileup columns
      def each(&block : {Int32, Int64, Array(Array(Alignment))} ->)
        while result = self.next
          yield result
        end
      end
      
      # Set maximum depth per file
      def max_depth=(depth : Int32)
        LibHTS.bam_mplp_set_maxcnt(@mplp, depth)
      end
      
      # Enable/disable read-pair overlap detection
      # Must be called before first next() call
      def overlap_detection=(enabled : Bool)
        return if @overlap_detection_enabled == enabled
        
        if enabled
          ret = LibHTS.bam_mplp_init_overlaps(@mplp)
          raise "Failed to enable overlap detection" if ret < 0
        end
        
        @overlap_detection_enabled = enabled
      end
      
      # Reset iterator to beginning
      def reset
        LibHTS.bam_mplp_reset(@mplp)
      end
      
      # Close the iterator
      def close
        return if @closed
        LibHTS.bam_mplp_destroy(@mplp) unless @mplp.null?
        @closed = true
      end
      
      def finalize
        close unless @closed
      end
    end
    
    # Helper functions for pileup operations
    module Helper
      # Get insertion sequence at this position
      # Returns: {seq: insertion sequence, del_len: deletion length after insertion}
      def self.insertion(aln : Alignment) : {seq: String, del_len: Int32}
        ks = uninitialized LibHTS::KstringT
        ks.s = Pointer(UInt8).null
        ks.l = 0
        ks.m = 0
        
        del = 0
        n = LibHTS.bam_plp_insertion(aln.to_unsafe, pointerof(ks), pointerof(del))
        
        return {seq: "", del_len: 0} if n <= 0
        
        # Copy kstring.s to Crystal String
        seq = String.new(ks.s, ks.l.to_i)
        
        # Free kstring.s (allocated by malloc)
        LibC.free(ks.s.as(Void*)) unless ks.s.null?
        
        {seq: seq, del_len: del}
      end
    end
  end
end
