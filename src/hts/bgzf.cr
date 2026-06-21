require "./libhts"
require "./hts"

module HTS
  class Bgzf < Hts
    class Error < HTS::Error
    end

    class OpenError < Error
    end

    class ReadError < Error
    end

    class WriteError < Error
    end

    class FileFormatError < Error
    end

    @nthreads : Int32?
    @hts_file : LibHTS::HtsFile*

    getter :file_name
    getter :mode

    def self.open(file_name : Path | String, mode = "r", threads = 0)
      new(file_name, mode, threads)
    end

    def self.open(file_name : Path | String, mode = "r", threads = 0, &)
      file = new(file_name, mode, threads)
      begin
        yield file
      ensure
        file.close
      end
    end

    def initialize(@file_name : Path | String, @mode = "r", threads = 0)
      @file_name = file_name.to_s || ""
      @hts_file = Pointer(LibHTS::HtsFile).null

      begin
        # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

        @hts_file = LibHTS.hts_open(@file_name.to_s.to_unsafe, @mode.to_unsafe)

        raise OpenError.new("Failed to open file #{@file_name}") if @hts_file.null?

        set_threads(threads) if threads > 0

        @start_position = tell
      rescue ex
        close rescue nil
        raise ex
      end
    end

    # Standard IO methods

    def getc : Char?
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      return if bgzf_fp.null?

      result = LibHTS.bgzf_getc(bgzf_fp)
      return if result < 0
      result.chr
    end

    def gets(delimiter = '\n') : String?
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)

      str = LibHTS::KstringT.new
      str.l = 0
      str.m = 0
      str.s = Pointer(LibC::Char).null

      begin
        result =
          if bgzf_fp.null?
            # Fall back to HTS file reading
            LibHTS.hts_getline(@hts_file, delimiter.ord, pointerof(str))
          else
            LibHTS.bgzf_getline(bgzf_fp, delimiter.ord, pointerof(str))
          end

        if result < 0 || str.s.null?
          nil
        else
          String.new(str.s, str.l)
        end
      ensure
        LibC.free(str.s) unless str.s.null?
      end
    end

    def puts(data : String) : Int64
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      raise FileFormatError.new("Not a BGZF file") if bgzf_fp.null?

      # Write the string
      bytes_written = LibHTS.bgzf_write(bgzf_fp, data.to_unsafe, data.bytesize)
      raise WriteError.new("Failed to write BGZF data") if bytes_written < 0

      # Write newline
      newline_written = LibHTS.bgzf_write(bgzf_fp, "\n".to_unsafe, 1)
      raise WriteError.new("Failed to write BGZF newline") if newline_written < 0

      bytes_written + newline_written
    end

    def read(size : Int32) : Bytes
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      raise FileFormatError.new("Not a BGZF file") if bgzf_fp.null?

      buffer = Bytes.new(size)
      bytes_read = LibHTS.bgzf_read(bgzf_fp, buffer.to_unsafe, size)

      if bytes_read < 0
        raise ReadError.new("Failed to read from BGZF file")
      elsif bytes_read == 0
        Bytes.empty
      else
        buffer[0, bytes_read]
      end
    end

    def write(data : String) : Int64
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      raise FileFormatError.new("Not a BGZF file") if bgzf_fp.null?

      bytes_written = LibHTS.bgzf_write(bgzf_fp, data.to_unsafe, data.bytesize)
      raise WriteError.new("Failed to write BGZF data") if bytes_written < 0

      bytes_written
    end

    def write(data : Bytes) : Int64
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      raise FileFormatError.new("Not a BGZF file") if bgzf_fp.null?

      bytes_written = LibHTS.bgzf_write(bgzf_fp, data.to_unsafe, data.size)
      raise WriteError.new("Failed to write BGZF data") if bytes_written < 0

      bytes_written
    end

    def flush : Int32
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      return 0 if bgzf_fp.null?

      LibHTS.bgzf_flush(bgzf_fp)
    end

    def finalize
      close unless closed?
    rescue
      nil
    end

    # Iterator methods

    def each_line(delimiter = '\n', &)
      check_closed
      while line = gets(delimiter)
        yield line
      end
      self
    end

    def each_char(&)
      check_closed
      while char = getc
        yield char
      end
      self
    end

    # BGZF specific methods

    def compression_level : Int32
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      return -1 if bgzf_fp.null?

      LibHTS.bgzf_compression(bgzf_fp)
    end

    def bgzf? : Bool
      !LibHTS.hts_get_bgzfp(@hts_file).null?
    end

    # ameba:disable Naming/PredicateName
    def is_bgzf? : Bool
      bgzf?
    end

    # ameba:enable Naming/PredicateName

    # Override seek and tell for BGZF-specific behavior
    def seek(offset)
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      if bgzf_fp.null?
        super(offset)
      else
        LibHTS.bgzf_seek(bgzf_fp, offset, IO::Seek::Set)
      end
    end

    def tell
      check_closed
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      if bgzf_fp.null?
        super
      else
        LibHTS2.bgzf_tell(bgzf_fp)
      end
    end
  end
end
