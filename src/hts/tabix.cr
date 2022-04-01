require "./libhts"
require "./version"

module HTS
  class Tabix
    getter :file_name
    getter :mode

    def self.open(file_name : Path | String, mode = "r", threads = 0)
      new(file_name, mode, threads)
    end

    def self.open(file_name : Path | String, mode = "r", threads = 0)
      file = new(file_name, mode, threads)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(@file_name : Path | String, mode = "r", threads = 0)

      if mode[0] == 'r' && !File.exists?(file_name)
        raise "File not found: #{file_name}"
      end

      @mode = mode
      @hts_file = LibHTS.hts_open(file_name, mode)

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        r < 0 && raise "Failed to set number threads: #{r}"
      end

      # FIXME: Loading index needed for query
    end
  end
end
