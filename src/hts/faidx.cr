require "./libhts"
require "./version"

module HTS
  class Faidx
    getter :file_name

    def self.open(file_name : Path | String)
      new(file_name)
    end

    def self.open(file_name : Path | String)
      file = new(file_name)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String)
      @file_name = file_name.to_s || ""
      @fai = LibHTS.fai_load(file_name)
      raise "Failed to load fai file: #{file_name}" if @fai.null?
    end

    def struct
      @fai
    end

    def close
      LibHTS.fai_destroy(@fai)
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
      chrom = chrom.to_s || ""
      result = LibHTS.faidx_seq_len(@fai, chrom)
    end

    def chrom_names
      Array.new(length) do |i|
        String.new(LibHTS.faidx_iseq(@fai, i))
      end
    end

    def seq(name : String | Symbol, start : Number, stop : Number)
      name = name.to_s || ""
      rlen = Pointer(Int32).malloc
      result = LibHTS.faidx_fetch_seq(@fai, name, start, stop, rlen)
      case rlen.value
      when -2 then raise "Invalid chromosome name: #{name}"
      when -1 then raise "Error fetching sequence: #{name}:#{start}-#{stop}"
      end
      String.new(result)
    end

    def seq(name : String | Symbol)
      name = name.to_s || ""
      rlen = Pointer(Int32).malloc
      result = LibHTS.fai_fetch(@fai, name, rlen)
      case rlen.value
      when -2 then raise "Invalid chromosome name: #{name}"
      when -1 then raise "Error fetching sequence: #{name}"
      end
      String.new(result)
    end

    def finalize
      close
    end
  end
end
