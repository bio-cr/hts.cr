require "./libhts"

module HTS
  class Hts
    HTS_FILE_CRAM = 1_u32 << 3
    HTS_FILE_BGZF = 1_u32 << 4

    @start_position : Int64?
    @mode : String = ""

    macro define_getter(name)
      def {{ name.id }}
        check_closed
        position = tell
        begin
          ary = map do |record|
            record.{{ name.id }}
          end
        ensure
          if position.nil?
            STDERR.puts "Warning: #{@file_name} is not seekable"
          else
            seek(position)
          end
        end
        ary
      end
    end

    macro define_iterator(name)
      def each_{{ name.id }}
        check_closed
        each do |record|
          yield record.{{ name.id }}
        end
        self
      end
    end

    def to_unsafe
      @hts_file
    end

    def file_format
      check_closed
      format = LibHTS.hts_get_format(@hts_file)
      raise FileFormatError.new("Failed to inspect file format for #{@file_name}") if format.null?
      format.value.format.to_s
    end

    def file_format_version
      check_closed
      format = LibHTS.hts_get_format(@hts_file)
      raise FileFormatError.new("Failed to inspect file format version for #{@file_name}") if format.null?
      v = format.value.version
      major = v.major
      minor = v.minor
      if minor == -1
        "#{major}"
      else
        "#{major}.#{minor}"
      end
    end

    def close
      close_hts_file
    end

    def closed?
      @hts_file.null?
    end

    def threads=(n)
      set_threads(n)
    end

    # ameba:disable Naming/AccessorMethodName
    def set_threads(n)
      check_closed
      if n > 0
        r = LibHTS.hts_set_threads(@hts_file, n)
        raise ThreadError.new("Failed to set number of threads: #{n}") if r < 0
        @nthreads = n
      end
    end

    # ameba:enable Naming/AccessorMethodName

    private def check_closed
      raise IO::Error.new("Closed stream") if closed?
    end

    protected def close_hts_file
      return if closed?
      rc = LibHTS.hts_close(@hts_file)
      @hts_file = @hts_file.class.null
      raise close_error if rc < 0 && close_error_fatal?
    end

    protected def close_error_fatal?
      @mode.includes?('w') || @mode.includes?('a')
    end

    protected def close_error : Exception
      CloseError.new("Failed to close file")
    end

    protected def self.close_after_yield(file, &)
      result = yield file
    rescue ex
      file.close rescue nil
      raise ex
    else
      file.close
      result
    end

    def seek(offset)
      check_closed
      flags = @hts_file.value.flags
      if flags & HTS_FILE_CRAM != 0
        LibHTS.cram_seek(@hts_file.value.fp.cram, offset, IO::Seek::Set)
      elsif flags & HTS_FILE_BGZF != 0
        LibHTS.bgzf_seek(@hts_file.value.fp.bgzf, offset, IO::Seek::Set)
      else # hfile
        LibHTS.hseek(@hts_file.value.fp.hfile, offset, IO::Seek::Set)
      end
    end

    def tell
      check_closed
      flags = @hts_file.value.flags
      if flags & HTS_FILE_CRAM != 0
        # LibHTS.cram_tell(@hts_file.value.fp.cram)
        # "cram_tell is not implemented"
        nil
      elsif flags & HTS_FILE_BGZF != 0
        LibHTS2.bgzf_tell(@hts_file.value.fp.bgzf).to_i64
      else # hfile
        LibHTS2.htell(@hts_file.value.fp.hfile).to_i64
      end
    end

    def rewind
      check_closed
      flags = @hts_file.value.flags
      if flags & HTS_FILE_CRAM != 0
        # For CRAM files, seek directly to the beginning (tell is not available)
        r = LibHTS.cram_seek(@hts_file.value.fp.cram, 0, IO::Seek::Set)
        raise RewindError.new("Failed to rewind CRAM file: #{r}") if r < 0
        nil # Return nil as tell is not available
      else
        # bam / sam
        if start_position = @start_position
          r = seek(start_position)
          raise RewindError.new("Failed to rewind: #{r}") if r < 0
          tell
        else
          raise RewindError.new("Cannot rewind: no start position")
        end
      end
    end
  end
end
