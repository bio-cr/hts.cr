require "./libhts"

module HTS
  class Hts

    @start_position : (Int64 | Nil)

    def struct
      @hts_file
    end

    def seek(offset)
      # FIXME: Use bit fields
      flags = @hts_file.value.flags
      if (flags & "1000".to_i(2) != 0) # cram
        LibHTS.cram_seek(@hts_file.value.fp.cram, offset, IO::SEEK_SET)
      elsif (flags & "10000".to_i(2) != 0) # bgzf
        LibHTS.bgzf_seek(@hts_file.value.fp.bgzf, offset, IO::SEEK_SET)
      else # hfile
        LibHTS.hseek(@hts_file.value.fp.hfile, offset, IO::SEEK_SET)
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
      seek(@start_position) if @start_position
      # raise error unless @start_position
    end
    
    def format
      LibHTS.hts_get_format(@hts_file).value.format.to_s
    end

    def format_version
      v = LibHTS.hts_get_format(@hts_file).value.version
      major = v.major
      minor = v.minor
      if minor == -1
        "#{major}"
      else
        "#{major}.#{minor}"
      end
    end
  end
end