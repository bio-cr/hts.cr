require "benchmark"
require "../src/hts/bcf"

module BcfScanBenchmark
  DEFAULT_RECORDS = 10_000
  DEFAULT_SAMPLES =     64

  extend self

  @@sink = 0_u64

  def consume(value : Int64 | UInt64) : Nil
    @@sink &+= value.to_u64
  end

  def generate_fixture(path : String, record_count : Int32, sample_count : Int32) : Nil
    raise ArgumentError.new("record count must be positive") unless record_count > 0
    raise ArgumentError.new("sample count must be positive") unless sample_count > 0

    header = HTS::Bcf::Header.new
    header.version = "VCFv4.3"
    header.append("##contig=<ID=1,length=#{record_count + 1}>")
    header.append("##INFO=<ID=AC,Number=A,Type=Integer,Description=\"Allele count\">")
    header.append("##INFO=<ID=AF,Number=A,Type=Float,Description=\"Allele frequency\">")
    header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
    header.append("##FORMAT=<ID=DP,Number=1,Type=Integer,Description=\"Read depth\">")
    header.append("##FORMAT=<ID=AD,Number=R,Type=Integer,Description=\"Allele depths\">")
    sample_count.times do |sample_index|
      header.add_sample("S#{sample_index + 1}", sync: false)
    end
    header.sync

    genotypes = Array(Int32).new(sample_count * 2, 0)
    depths = Array(Int32).new(sample_count, 0)
    allele_depths = Array(Int32).new(sample_count * 2, 0)

    HTS::Bcf.open(path, "wb") do |bcf|
      bcf.write_header(header)
      record = HTS::Bcf::Record.new(header)
      record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
      rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
      raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

      record_count.times do |record_index|
        record.pos = record_index

        sample_count.times do |sample_index|
          offset = sample_index * 2
          first_allele = (record_index + sample_index) % 2
          second_allele = (record_index + sample_index + 1) % 2
          genotypes[offset] = HTS::LibHTS2.bcf_gt_unphased(first_allele)
          genotypes[offset + 1] = if (record_index + sample_index) % 19 == 0
                                    HTS::LibHTS2.bcf_gt_missing
                                  elsif (record_index + sample_index).even?
                                    HTS::LibHTS2.bcf_gt_phased(second_allele)
                                  else
                                    HTS::LibHTS2.bcf_gt_unphased(second_allele)
                                  end

          depth = 10 + ((record_index + sample_index) % 90)
          depths[sample_index] = depth
          allele_depths[offset] = depth // 3
          allele_depths[offset + 1] = depth - allele_depths[offset]
        end

        record.format.update_genotypes(genotypes)
        record.format.update_int("DP", depths)
        record.format.update_int("AD", allele_depths)
        record.info.update_int("AC", record_index % (sample_count * 2 + 1))
        record.info.update_float("AF", (record_index % 101).to_f32 / 100_f32)
        bcf << record
      end
    end
  end

  abstract class Scanner
    def initialize(path : String)
      @bcf = HTS::Bcf.new(path)
    end

    def close : Nil
      @bcf.close unless @bcf.closed?
    end

    protected def rewind_after(&)
      yield
    ensure
      @bcf.rewind
    end
  end

  class HighLevelScanner < Scanner
    def scan_genotypes : Int64
      rewind_after do
        checksum = 0_i64
        @bcf.each do |record|
          values = record.format.genotypes || raise "GT missing from benchmark fixture"
          values.each { |value| checksum &+= value }
        end
        checksum
      end
    end

    def scan_genotype_strings : UInt64
      rewind_after do
        checksum = 0_u64
        @bcf.each do |record|
          values = record.format.get_string("GT") || raise "GT missing from benchmark fixture"
          values.each do |value|
            value.to_slice.each { |byte| checksum &+= byte }
          end
        end
        checksum
      end
    end

    def scan_genotype_alleles : Int64
      rewind_after do
        checksum = 0_i64
        @bcf.each do |record|
          present = record.format.each_genotype do |sample_index, genotype|
            checksum &+= sample_index
            genotype.each_allele do |allele_index, phased, missing|
              checksum &+= allele_index
              checksum &+= 3 if phased
              checksum &+= 5 if missing
            end
          end
          raise "GT missing from benchmark fixture" unless present
        end
        checksum
      end
    end

    def scan_last_genotype : Int64
      rewind_after do
        checksum = 0_i64
        sample_index = @bcf.header.nsamples - 1
        @bcf.each do |record|
          present = record.format.genotype_at("GT", sample_index) do |genotype|
            genotype.each_allele do |allele_index, phased, missing|
              checksum &+= allele_index
              checksum &+= 3 if phased
              checksum &+= 5 if missing
            end
          end
          raise "GT missing from benchmark fixture" unless present
        end
        checksum
      end
    end

    def scan_format_i32(tag : String) : Int64
      rewind_after do
        checksum = 0_i64
        @bcf.each do |record|
          values = record.format.get_int(tag) || raise "FORMAT/#{tag} missing from benchmark fixture"
          values.each { |value| checksum &+= value }
        end
        checksum
      end
    end

    def scan_format_i32_borrowed(tag : String) : Int64
      rewind_after do
        checksum = 0_i64
        @bcf.each do |record|
          present = record.format.with_i32_buffer(tag) do |values|
            values.each { |value| checksum &+= value }
          end
          raise "FORMAT/#{tag} missing from benchmark fixture" unless present
        end
        checksum
      end
    end

    def scan_info_i32(tag : String) : Int64
      rewind_after do
        checksum = 0_i64
        @bcf.each do |record|
          values = record.info.get_int(tag) || raise "INFO/#{tag} missing from benchmark fixture"
          values.each { |value| checksum &+= value }
        end
        checksum
      end
    end

    def scan_info_i32_borrowed(tag : String) : Int64
      rewind_after do
        checksum = 0_i64
        @bcf.each do |record|
          present = record.info.with_i32_buffer(tag) do |values|
            values.each { |value| checksum &+= value }
          end
          raise "INFO/#{tag} missing from benchmark fixture" unless present
        end
        checksum
      end
    end

    def scan_info_f32(tag : String) : UInt64
      rewind_after do
        checksum = 0_u64
        @bcf.each do |record|
          values = record.info.get_float(tag) || raise "INFO/#{tag} missing from benchmark fixture"
          values.each { |value| checksum &+= value.unsafe_as(UInt32) }
        end
        checksum
      end
    end

    def scan_info_f32_borrowed(tag : String) : UInt64
      rewind_after do
        checksum = 0_u64
        @bcf.each do |record|
          present = record.info.with_f32_buffer(tag) do |values|
            values.each { |value| checksum &+= value.unsafe_as(UInt32) }
          end
          raise "INFO/#{tag} missing from benchmark fixture" unless present
        end
        checksum
      end
    end
  end

  class LowLevelScanner < Scanner
    def initialize(path : String)
      super
      @record = HTS::LibHTS.bcf_init
      raise "bcf_init failed" if @record.null?
      @i32_buffer = Pointer(Void).null
      @i32_capacity = 0
      @f32_buffer = Pointer(Void).null
      @f32_capacity = 0
    end

    def close : Nil
      HTS::LibHTS.bcf_destroy(@record) unless @record.null?
      @record = Pointer(HTS::LibHTS::Bcf1T).null
      HTS::LibHTS.hts_free(@i32_buffer) unless @i32_buffer.null?
      @i32_buffer = Pointer(Void).null
      HTS::LibHTS.hts_free(@f32_buffer) unless @f32_buffer.null?
      @f32_buffer = Pointer(Void).null
      super
    end

    def scan_genotypes : Int64
      scan_i32 do |header, record|
        HTS::LibHTS2.bcf_get_genotypes(
          header,
          record,
          pointerof(@i32_buffer),
          pointerof(@i32_capacity)
        )
      end
    end

    def scan_format_i32(tag : String) : Int64
      scan_i32 do |header, record|
        HTS::LibHTS2.bcf_get_format_int32(
          header,
          record,
          tag,
          pointerof(@i32_buffer),
          pointerof(@i32_capacity)
        )
      end
    end

    def scan_info_i32(tag : String) : Int64
      scan_i32 do |header, record|
        HTS::LibHTS2.bcf_get_info_int32(
          header,
          record,
          tag,
          pointerof(@i32_buffer),
          pointerof(@i32_capacity)
        )
      end
    end

    def scan_info_f32(tag : String) : UInt64
      rewind_after do
        checksum = 0_u64
        each_record do |header, record|
          count = HTS::LibHTS2.bcf_get_info_float(
            header,
            record,
            tag,
            pointerof(@f32_buffer),
            pointerof(@f32_capacity)
          )
          raise "failed to read INFO/#{tag} (rc=#{count})" if count < 0
          values = @f32_buffer.as(Pointer(Float32))
          count.times { |index| checksum &+= values[index].unsafe_as(UInt32) }
        end
        checksum
      end
    end

    private def scan_i32(& : HTS::LibHTS::BcfHdrT*, HTS::LibHTS::Bcf1T* -> Int32) : Int64
      rewind_after do
        checksum = 0_i64
        each_record do |header, record|
          count = yield header, record
          raise "failed to read benchmark field (rc=#{count})" if count < 0
          values = @i32_buffer.as(Pointer(Int32))
          count.times { |index| checksum &+= values[index] }
        end
        checksum
      end
    end

    private def each_record(& : HTS::LibHTS::BcfHdrT*, HTS::LibHTS::Bcf1T* ->) : Nil
      header = @bcf.header.to_unsafe
      while (rc = HTS::LibHTS.bcf_read(@bcf.to_unsafe, header, @record)) >= 0
        yield header, @record
      end
      raise "bcf_read failed (rc=#{rc})" if rc < -1
    end
  end

  def verify!(high : HighLevelScanner, low : LowLevelScanner) : Nil
    comparisons = {
      "GT/raw"           => {high.scan_genotypes, low.scan_genotypes},
      "GT/borrowed"      => {high.scan_format_i32_borrowed("GT"), low.scan_genotypes},
      "DP"               => {high.scan_format_i32("DP"), low.scan_format_i32("DP")},
      "DP/borrowed"      => {high.scan_format_i32_borrowed("DP"), low.scan_format_i32("DP")},
      "AD"               => {high.scan_format_i32("AD"), low.scan_format_i32("AD")},
      "AD/borrowed"      => {high.scan_format_i32_borrowed("AD"), low.scan_format_i32("AD")},
      "INFO/AC"          => {high.scan_info_i32("AC"), low.scan_info_i32("AC")},
      "INFO/AC borrowed" => {high.scan_info_i32_borrowed("AC"), low.scan_info_i32("AC")},
      "INFO/AF"          => {high.scan_info_f32("AF"), low.scan_info_f32("AF")},
      "INFO/AF borrowed" => {high.scan_info_f32_borrowed("AF"), low.scan_info_f32("AF")},
    }

    comparisons.each do |label, pair|
      high_value, low_value = pair
      raise "checksum mismatch for #{label}: high=#{high_value}, low=#{low_value}" unless high_value == low_value
    end
  end

  def run : Nil
    path = ARGV[0]? || File.join(Dir.tempdir, "hts-cr-bcf-benchmark.bcf")
    record_count = ENV.fetch("HTS_BENCH_RECORDS", DEFAULT_RECORDS.to_s).to_i32
    sample_count = ENV.fetch("HTS_BENCH_SAMPLES", DEFAULT_SAMPLES.to_s).to_i32
    regenerate = ENV["HTS_BENCH_REGENERATE"]? == "1"

    if regenerate || !File.exists?(path)
      puts "Generating #{path} (records=#{record_count}, samples=#{sample_count})"
      generate_fixture(path, record_count, sample_count)
    end

    high = HighLevelScanner.new(path)
    low = LowLevelScanner.new(path)
    begin
      verify!(high, low)
      puts "Verified high-level and low-level checksums"
      return if ENV["HTS_BENCH_VERIFY_ONLY"]? == "1"

      calculation = ENV.fetch("HTS_BENCH_SECONDS", "2").to_f.seconds
      warmup = ENV.fetch("HTS_BENCH_WARMUP", "1").to_f.seconds
      Benchmark.ips(calculation: calculation, warmup: warmup, interactive: false) do |job|
        job.report("GT low-level raw") { consume(low.scan_genotypes) }
        job.report("GT high-level raw") { consume(high.scan_genotypes) }
        job.report("GT borrowed raw") { consume(high.scan_format_i32_borrowed("GT")) }
        job.report("GT allele iterator") { consume(high.scan_genotype_alleles) }
        job.report("GT last sample") { consume(high.scan_last_genotype) }
        job.report("GT high-level strings") { consume(high.scan_genotype_strings) }
        job.report("DP low-level") { consume(low.scan_format_i32("DP")) }
        job.report("DP high-level") { consume(high.scan_format_i32("DP")) }
        job.report("DP borrowed") { consume(high.scan_format_i32_borrowed("DP")) }
        job.report("AD low-level") { consume(low.scan_format_i32("AD")) }
        job.report("AD high-level") { consume(high.scan_format_i32("AD")) }
        job.report("AD borrowed") { consume(high.scan_format_i32_borrowed("AD")) }
        job.report("INFO/AC low-level") { consume(low.scan_info_i32("AC")) }
        job.report("INFO/AC high-level") { consume(high.scan_info_i32("AC")) }
        job.report("INFO/AC borrowed") { consume(high.scan_info_i32_borrowed("AC")) }
        job.report("INFO/AF low-level") { consume(low.scan_info_f32("AF")) }
        job.report("INFO/AF high-level") { consume(high.scan_info_f32("AF")) }
        job.report("INFO/AF borrowed") { consume(high.scan_info_f32_borrowed("AF")) }
      end
    ensure
      low.close
      high.close
    end
  end
end

BcfScanBenchmark.run
