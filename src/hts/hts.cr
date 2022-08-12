require "./libhts"

module HTS
  class Hts
    @start_position : (Int64 | Nil)

    macro define_getter(name)
      def {{name.id}}
        check_closed
        position = tell
        ary = map do |record|
          record.{{name.id}}
        end
        if position.nil?
          STDERR.puts "Warning: #{@file_name} is not seekable"
        else
          seek(position)
        end
        ary
      end
    end

    macro define_iterator(name)
      def each_{{name.id}}
        check_closed
        each do |record|
          yield record.{{name.id}}
        end
        self
      end
    end

    def struct
      @hts_file
    end

    def file_format
      LibHTS.hts_get_format(@hts_file).value.format.to_s
    end

    def file_format_version
      v = LibHTS.hts_get_format(@hts_file).value.version
      major = v.major
      minor = v.minor
      if minor == -1
        "#{major}"
      else
        "#{major}.#{minor}"
      end
    end

    def close
      return if closed?
      LibHTS.hts_close(@hts_file)
      @hts_file = @hts_file.class.null
    end

    def closed?
      @hts_file.null?
    end

    def set_threads(n)
      if n > 0
        r = LibHTS.hts_set_threads(@hts_file, n)
        raise "Failed to set number of threads: #{n}" if r < 0
        @nthreads = n
      end
    end

    private def check_closed
      raise IO::Error.new("Closed stream") if closed?
    end

    def seek(offset)
      # FIXME: Use bit fields
      flags = @hts_file.value.flags
      if (flags & "1000".to_i(2) != 0) # cram
        LibHTS.cram_seek(@hts_file.value.fp.cram, offset, IO::Seek::Set)
      elsif (flags & "10000".to_i(2) != 0) # bgzf
        LibHTS.bgzf_seek(@hts_file.value.fp.bgzf, offset, IO::Seek::Set)
      else # hfile
        LibHTS.hseek(@hts_file.value.fp.hfile, offset, IO::Seek::Set)
      end
    end

    def tell
      flags = @hts_file.value.flags
      if (flags & "1000".to_i(2) != 0) # cram
        # LibHTS.cram_tell(@hts_file.value.fp.cram)
        # "cram_tell is not implemented"
        nil
      elsif (flags & "10000".to_i(2) != 0) # bgzf
        LibHTS2.bgzf_tell(@hts_file.value.fp.bgzf)
      else # hfile
        LibHTS2.htell(@hts_file.value.fp.hfile)
      end
    end

    def rewind
      if @start_position
        r = seek(@start_position)
        raise "Failed to rewind: #{r}" if r < 0

        tell
      else
        raise "Cannot rewind: no start position"
      end
    end
  end
end
