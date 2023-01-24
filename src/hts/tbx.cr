require "./libhts"
require "./version"

require "./hts"
require "./tbx/record"

module HTS
  class Tbx < Hts
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

    def initialize(@file_name : Path | String, @mode = "r", threads = 0)
      @file_name = file_name.to_s || ""

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @hts_file = LibHTS.hts_open(@file_name, @mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      set_threads(threads) if threads > 0

      # FIXME: Loading index needed for query
    end
  end
end
