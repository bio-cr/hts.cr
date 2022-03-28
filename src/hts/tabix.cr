require "./libhts"
require "./version"

module HTS
  class Tabix
    getter :file_path
    getter :mode

    def self.open(filename : Path | String, mode = "r", threads = 0)
      new(filename, mode, threads)
    end

    def self.open(filename : Path | String, mode = "r", threads = 0)
      file = new(filename, mode, threads)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(filename : Path | String, mode = "r", threads = 0)
      @file_path = filename == "-" ? "-" : File.expand_path(filename)

      if mode[0] == 'r' && !File.exists?(file_path)
        raise "File not found: #{file_path}"
      end

      @mode = mode
      @hts_file = LibHTS.hts_open(file_path, mode)

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        r < 0 && raise "Failed to set number threads: #{r}"
      end

      # FIXME: Loading index needed for query
    end
  end
end
