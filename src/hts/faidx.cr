require "./libhts"
require "./version"

module HTS
  class Faidx
    getter :file_name

    def self.open(file_name : Path | String)
      new(file_name)
    end

    def self.open(file_name : Path | String, &)
      file = new(file_name)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String)
      @file_name = file_name.to_s
      @fai = LibHTS.fai_load(@file_name)
      @closed = false
      raise "Failed to load fai file: #{file_name}" if @fai.null?
    end

    def to_unsafe
      @fai
    end

    def close
      return if @closed
      LibHTS.fai_destroy(@fai)
      @closed = true
    end

    # FIXME: This doesn't seem to work as expected
    # def closed?
    #   @fai.null?
    # end

    def length
      LibHTS.faidx_nseq(@fai)
    end

    def size
      length
    end

    def chrom_size(chrom : String | Symbol)
      chrom = chrom.to_s
      result = LibHTS.faidx_seq_len(@fai, chrom)
    end

    def chrom_names
      Array.new(length) do |i|
        String.new(LibHTS.faidx_iseq(@fai, i))
      end
    end

    def seq(name : String | Symbol, start : Number, stop : Number)
      name = name.to_s
      result = LibHTS.faidx_fetch_seq(@fai, name, start, stop, out len)
      case len
      when -2 then raise "Invalid chromosome name: #{name}"
      when -1 then raise "Error fetching sequence: #{name}:#{start}-#{stop}"
      end
      str = String.new(result)
      LibC.free(result.as(Void*))
      str
    end

    def seq(name : String | Symbol)
      name = name.to_s
      result = LibHTS.fai_fetch(@fai, name, out len)
      case len
      when -2 then raise "Invalid chromosome name: #{name}"
      when -1 then raise "Error fetching sequence: #{name}"
      end
      str = String.new(result)
      LibC.free(result.as(Void*))
      str
    end

    def finalize
      close unless @closed
    end
  end
end
