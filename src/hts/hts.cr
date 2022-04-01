require "./libhts"

module HTS
  class Hts
    def struct
      @hts_file
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