require "./libhts"
require "./version"
require "./error"

module HTS
  class Faidx
    class Error < HTS::Error
    end

    class IndexError < Error
    end

    class OpenError < Error
    end

    class ReadError < Error
    end

    class FileFormatError < Error
    end

    @fai : LibHTS::FaidxT
    @closed : Bool
    @format : Symbol

    getter :file_name, :format

    def self.open(file_name : Path | String, *, format : Symbol = :auto, auto_build : Bool = true)
      new(file_name, format: format, auto_build: auto_build)
    end

    def self.open(file_name : Path | String, *, format : Symbol = :auto, auto_build : Bool = true, &)
      file = new(file_name, format: format, auto_build: auto_build)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def self.build_index(file_name : Path | String, fai_path : String? = nil, gzi_path : String? = nil)
      file_name = file_name.to_s
      fai_ptr = fai_path ? fai_path.to_unsafe : Pointer(LibC::Char).null
      gzi_ptr = gzi_path ? gzi_path.to_unsafe : Pointer(LibC::Char).null
      r = LibHTS.fai_build3(file_name, fai_ptr, gzi_ptr)
      raise IndexError.new("Failed to build faidx index for #{file_name}") if r != 0
    end

    def initialize(file_name : Path | String, *, format : Symbol = :auto, auto_build : Bool = true)
      @file_name = file_name.to_s
      @format = resolve_format(@file_name, format)
      @fai = load_handle(@file_name, @format, auto_build)
      @closed = false
      raise OpenError.new("Failed to load faidx for #{@file_name}") if @fai.null?
    end

    def to_unsafe
      @fai
    end

    def close
      return if @closed
      LibHTS.fai_destroy(@fai)
      @fai = Pointer(Void).null.as(LibHTS::FaidxT)
      @closed = true
    end

    def closed?
      @closed
    end

    def size
      check_closed
      LibHTS.faidx_nseq(@fai)
    end

    def length
      size
    end

    def names
      check_closed
      Array.new(size) do |i|
        name = LibHTS.faidx_iseq(@fai, i)
        raise ReadError.new("Failed to load sequence name at index #{i} for #{@file_name}") if name.null?
        String.new(name)
      end
    end

    def has_seq?(name : String | Symbol)
      check_closed
      case LibHTS.faidx_has_seq(@fai, name.to_s)
      when 1 then true
      when 0 then false
      else        raise ReadError.new("Unexpected return value from faidx_has_seq")
      end
    end

    def seq_len(name : String | Symbol)
      check_closed
      name = name.to_s
      len = LibHTS.faidx_seq_len64(@fai, name)
      raise ArgumentError.new("Sequence not found: #{name}") if len < 0
      len
    end

    def fetch_seq(name : String | Symbol)
      name = name.to_s
      len = seq_len(name)
      return "" if len == 0
      fetch_seq(name, 0_i64, len - 1)
    end

    def fetch_seq(name : String | Symbol, start : Int, stop : Int)
      fetch_seq_impl(name.to_s, start.to_i64, stop.to_i64)
    end

    def fetch_qual(name : String | Symbol)
      ensure_fastq!
      name = name.to_s
      len = seq_len(name)
      return "" if len == 0
      fetch_qual(name, 0_i64, len - 1)
    end

    def fetch_qual(name : String | Symbol, start : Int, stop : Int)
      ensure_fastq!
      fetch_qual_impl(name.to_s, start.to_i64, stop.to_i64)
    end

    def build_index(fai_path : String? = nil, gzi_path : String? = nil)
      self.class.build_index(@file_name, fai_path, gzi_path)
      self
    end

    def finalize
      close unless @closed
    end

    private def load_handle(file_name : String, format : Symbol, auto_build : Bool)
      null = Pointer(LibC::Char).null
      case {format, auto_build}
      when {:fasta, true}
        LibHTS.fai_load_format(file_name, LibHTS::FaiFormatOptions::FaiFasta)
      when {:fastq, true}
        LibHTS.fai_load_format(file_name, LibHTS::FaiFormatOptions::FaiFastq)
      when {:fasta, false}
        LibHTS.fai_load3_format(file_name, null, null, 0, LibHTS::FaiFormatOptions::FaiFasta)
      when {:fastq, false}
        LibHTS.fai_load3_format(file_name, null, null, 0, LibHTS::FaiFormatOptions::FaiFastq)
      else
        raise ArgumentError.new("Unsupported format: #{format}")
      end
    end

    private def resolve_format(file_name : String, format : Symbol)
      case format
      when :auto
        detect_format(file_name)
      when :fasta, :fastq
        format
      else
        raise ArgumentError.new("Unsupported format: #{format}")
      end
    end

    private def detect_format(file_name : String)
      file_name =~ /\.(fastq|fq)(\.gz|\.bgz)?\z/i ? :fastq : :fasta
    end

    private def fetch_seq_impl(name : String, start : Int64, stop : Int64)
      check_closed
      validate_range!(name, start, stop)
      ptr = LibHTS.faidx_fetch_seq64(@fai, name, start, stop, out len)
      case len
      when -2 then raise ArgumentError.new("Sequence not found: #{name}")
      when -1 then raise ReadError.new("Failed to fetch sequence: #{name}:#{start}-#{stop}")
      end
      read_owned_string(ptr, len, "sequence")
    end

    private def fetch_qual_impl(name : String, start : Int64, stop : Int64)
      check_closed
      validate_range!(name, start, stop)
      ptr = LibHTS.faidx_fetch_qual64(@fai, name, start, stop, out len)
      case len
      when -2 then raise ArgumentError.new("Sequence not found: #{name}")
      when -1 then raise ReadError.new("Failed to fetch quality: #{name}:#{start}-#{stop}")
      end
      read_owned_string(ptr, len, "quality")
    end

    private def read_owned_string(ptr : Pointer(LibC::Char), len : Int64, kind : String)
      raise ReadError.new("Failed to fetch #{kind}") if ptr.null?
      begin
        String.new(ptr, len.to_i)
      ensure
        LibC.free(ptr.as(Void*))
      end
    end

    private def validate_range!(name : String, start : Int64, stop : Int64)
      raise ArgumentError.new("start must be >= 0") if start < 0
      raise ArgumentError.new("stop must be >= 0") if stop < 0
      raise ArgumentError.new("start must be <= stop") if start > stop
      len = seq_len(name)
      raise ArgumentError.new("stop must be < seq_len (#{len})") if stop >= len
    end

    private def ensure_fastq!
      raise FileFormatError.new("Quality is only available for FASTQ indexes") unless @format == :fastq
    end

    private def check_closed
      raise IO::Error.new("Closed faidx") if closed?
    end
  end
end
