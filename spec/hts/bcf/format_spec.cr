require "../../spec_helper"
require "../../../src/hts/bcf"

class BcfFormatTest
  def with_temp_character_format_vcf(&)
    file = File.tempfile("format_character_test", ".vcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.puts "##fileformat=VCFv4.3"
      file.puts "##contig=<ID=1,length=100>"
      file.puts "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
      file.puts "##FORMAT=<ID=ST,Number=1,Type=String,Description=\"String field\">"
      file.puts "##FORMAT=<ID=CH,Number=1,Type=Character,Description=\"Character field\">"
      file.puts "##FORMAT=<ID=MISS,Number=1,Type=String,Description=\"defined but absent\">"
      file.puts "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tS1\tS2"
      file.puts "1\t10\t.\tA\tC\t.\tPASS\t.\tGT:ST:CH\t0/1:ALPHA:A\t1/1:BETA:Z"
      file.close

      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  def with_temp_bcf(&)
    file = File.tempfile("format_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.version = "VCFv4.3"
      header.append("##contig=<ID=1,length=100>")
      header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
      header.append("##FORMAT=<ID=PL,Number=G,Type=Integer,Description=\"Phred likelihoods\">")
      header.append("##FORMAT=<ID=MISSI,Number=1,Type=Integer,Description=\"defined but absent integer\">")
      header.append("##FORMAT=<ID=MISSF,Number=1,Type=Float,Description=\"defined but absent float\">")
      header.append("##FORMAT=<ID=IV,Number=.,Type=Integer,Description=\"integer with sentinels\">")
      header.append("##FORMAT=<ID=FV,Number=.,Type=Float,Description=\"float with sentinels\">")
      header.add_sample("S1", sync: false)
      header.add_sample("S2", sync: true)

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        genotypes = [
          HTS::LibHTS2.bcf_gt_unphased(0),
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(1),
        ]
        rc = HTS::LibHTS2.bcf_update_genotypes(header, record, genotypes.to_unsafe, genotypes.size)
        raise "bcf_update_genotypes failed (rc=#{rc})" if rc < 0

        likelihoods = [10, 20, 30, 40, 50, 60]
        rc = HTS::LibHTS2.bcf_update_format_int32(header, record, "PL", likelihoods.to_unsafe, likelihoods.size)
        raise "bcf_update_format_int32 failed (rc=#{rc})" if rc < 0

        int_with_sentinels = [10, HTS::LibHTS2.bcf_int32_vector_end, HTS::LibHTS2.bcf_int32_missing, HTS::LibHTS2.bcf_int32_vector_end]
        rc = HTS::LibHTS2.bcf_update_format_int32(header, record, "IV", int_with_sentinels.to_unsafe, int_with_sentinels.size)
        raise "bcf_update_format_int32 failed for IV (rc=#{rc})" if rc < 0

        float_with_sentinels = [1.5_f32, HTS::LibHTS2.bcf_float_vector_end, HTS::LibHTS2.bcf_float_missing, HTS::LibHTS2.bcf_float_vector_end]
        rc = HTS::LibHTS2.bcf_update_format_float(header, record, "FV", float_with_sentinels.to_unsafe, float_with_sentinels.size)
        raise "bcf_update_format_float failed for FV (rc=#{rc})" if rc < 0

        bcf << record
      end

      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  def with_temp_gt_bcf(&)
    file = File.tempfile("format_gt_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.version = "VCFv4.3"
      header.append("##contig=<ID=1,length=100>")
      header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
      header.add_sample("S1", sync: false)
      header.add_sample("S2", sync: false)
      header.add_sample("S3", sync: false)
      header.add_sample("S4", sync: true)

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        gt_vector_end = HTS::LibHTS2.bcf_gt_vector_end
        genotypes = [
          HTS::LibHTS2.bcf_gt_unphased(0), HTS::LibHTS2.bcf_gt_phased(1),
          HTS::LibHTS2.bcf_gt_unphased(0), HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_missing, HTS::LibHTS2.bcf_gt_missing,
          HTS::LibHTS2.bcf_gt_unphased(1), gt_vector_end,
        ]
        rc = HTS::LibHTS2.bcf_update_genotypes(header, record, genotypes.to_unsafe, genotypes.size)
        raise "bcf_update_genotypes failed (rc=#{rc})" if rc < 0

        bcf << record
      end

      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  def with_temp_format_source_vcf(&)
    file = File.tempfile("format_update_source", ".vcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.puts "##fileformat=VCFv4.3"
      file.puts "##contig=<ID=1,length=100>"
      file.puts "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">"
      file.puts "##FORMAT=<ID=GQ,Number=1,Type=Integer,Description=\"Genotype quality\">"
      file.puts "##FORMAT=<ID=TF,Number=1,Type=Float,Description=\"Float field\">"
      file.puts "##FORMAT=<ID=ST,Number=1,Type=String,Description=\"String field\">"
      file.puts "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tS1\tS2"
      file.puts "1\t10\t.\tA\tC\t.\tPASS\t.\tGT:GQ:TF:ST\t0/1:10:1.5:ALPHA\t1/1:20:2.5:BETA"
      file.close

      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  def with_temp_output_vcf(&)
    file = File.tempfile("format_update_output", ".vcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close
      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  def test_bcf_path
    File.expand_path("../../fixtures/test.bcf", __DIR__)
  end

  def format : HTS::Bcf::Format
    bcf = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) { HTS::Bcf.new(test_bcf_path) }
    rec = bcf.first
    bcf.close
    rec.format
  end

  def test_get_int
    (format.get_int("PL")).should eq([172, 93, 0])
  end

  def test_get_string
    (format.get_string("GT")).should eq(["1/1"])
  end

  def test_character_format_is_routed_through_string
    with_temp_character_format_vcf do |path|
      HTS::Bcf.open(path) do |bcf|
        format = bcf.first.format

        (bcf.header.format_type("CH")).should eq(:string)
        (bcf.header.format_type("ST")).should eq(:string)
        (format.get_string("ST")).should eq(["ALPHA", "BETA"])
        (format.get_string("CH")).should eq(["A", "Z"])
        (format.get_string("MISS")).should be_nil
      end
    end
  end

  def test_get_genotypes
    (format.get_genotypes).should eq([4, 4])
  end

  def test_getters_reuse_typed_scratch_buffers
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        format = record.format
        scratch = record.scratch

        (scratch.format_i32.null?).should be_true
        (scratch.format_f32.null?).should be_true
        (scratch.format_char.null?).should be_true

        (format.get_int("PL")).should eq([10, 20, 30, 40, 50, 60])
        int_pointer = scratch.format_i32
        int_capacity = scratch.format_i32_capacity
        (int_pointer.null?).should be_false
        (int_capacity > 0).should be_true

        (format.get_int("PL")).should eq([10, 20, 30, 40, 50, 60])
        (scratch.format_i32).should eq(int_pointer)
        (scratch.format_i32_capacity).should eq(int_capacity)

        (format.get_float("FV")).should_not be_nil
        (scratch.format_f32.null?).should be_false
        (format.get_string("GT")).should eq(["0/1", "1/1"])

        # GT shares Int32 storage; float getters use separate storage.
        (scratch.format_i32).should eq(int_pointer)
        (scratch.format_char.null?).should be_true
      end
    end

    with_temp_character_format_vcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        format = record.format
        scratch = record.scratch

        (format.get_string("ST")).should eq(["ALPHA", "BETA"])
        char_pointer = scratch.format_char
        char_capacity = scratch.format_char_capacity
        (char_pointer.null?).should be_false

        (format.get_string("CH")).should eq(["A", "Z"])
        (scratch.format_char).should eq(char_pointer)
        (scratch.format_char_capacity).should eq(char_capacity)
      end
    end
  end

  def test_borrowed_numeric_buffers
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        format = record.format

        yielded = false
        present = format.with_i32_buffer("PL") do |values|
          yielded = true
          (values).should eq(Slice[10, 20, 30, 40, 50, 60])
          (values.to_unsafe).should eq(record.scratch.format_i32)
          (values.size).should eq(6)
          (values.size <= record.scratch.format_i32_capacity).should be_true
        end
        (present).should be_true
        (yielded).should be_true

        format.with_f32_buffer("FV") do |values|
          (values.to_unsafe).should eq(record.scratch.format_f32)
          (values.size).should eq(4)
          (values[0]).should eq(1.5_f32)
        end.should be_true

        absent_yielded = false
        format.with_i32_buffer("MISSI") { absent_yielded = true }.should be_false
        (absent_yielded).should be_false
      end
    end
  end

  def test_multisample_gt_and_flat_numeric_buffers
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        format = bcf.first.format

        (format.get_string("GT")).should eq(["0/1", "1/1"])
        (format.get_genotypes).should eq([2, 4, 4, 4])
        (format.get_int("PL")).should eq([10, 20, 30, 40, 50, 60])

        ints = format.get_int("IV") || raise "IV should be present"
        (ints.size).should eq(4)
        (ints[0]).should eq(10)
        (HTS::LibHTS2.bcf_int32_is_vector_end(ints[1])).should eq(1)
        (HTS::LibHTS2.bcf_int32_is_missing(ints[2])).should eq(1)
        (HTS::LibHTS2.bcf_int32_is_vector_end(ints[3])).should eq(1)

        floats = format.get_float("FV") || raise "FV should be present"
        (floats.size).should eq(4)
        (floats[0]).should eq(1.5_f32)
        (HTS::LibHTS2.bcf_float_is_vector_end(floats[1])).should eq(1)
        (HTS::LibHTS2.bcf_float_is_missing(floats[2])).should eq(1)
        (HTS::LibHTS2.bcf_float_is_vector_end(floats[3])).should eq(1)

        (format.get_int("MISSI")).should be_nil
        (format.get_float("MISSF")).should be_nil
      end
    end
  end

  def test_gt_decoding_handles_phased_missing_and_lower_ploidy
    with_temp_gt_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        format = bcf.first.format
        raw = format.get_genotypes || raise "GT should be present"

        (raw.size).should eq(8)
        (HTS::LibHTS2.bcf_gt_allele(raw[0])).should eq(0)
        (HTS::LibHTS2.bcf_gt_allele(raw[1])).should eq(1)
        (HTS::LibHTS2.bcf_gt_is_phased(raw[1])).should eq(1)
        (HTS::LibHTS2.bcf_gt_is_missing(raw[2])).should eq(0)
        (HTS::LibHTS2.bcf_gt_is_missing(raw[3])).should eq(0)
        (HTS::LibHTS2.bcf_gt_allele(raw[6])).should eq(1)
        (HTS::LibHTS2.bcf_gt_is_vector_end(raw[7])).should eq(1)
        (format.get_string("GT")).should eq(["0|1", "0/1", "./.", "1"])
      end
    end
  end

  def test_low_level_contract
    expect_raises(HTS::Bcf::FormatDefinitionError) { format.get_int("NO_SUCH_TAG") }
    expect_raises(HTS::Bcf::FormatDefinitionError) { format.get_float("NO_SUCH_TAG") }
    expect_raises(HTS::Bcf::FormatDefinitionError) { format.get_string("NO_SUCH_TAG") }
    expect_raises(HTS::Bcf::FormatDefinitionError) { format.with_i32_buffer("NO_SUCH_TAG") { } }

    ex = expect_raises(HTS::Bcf::FormatTypeError) { format.get_float("PL") }
    (ex.message).should eq("Tag PL is not float FORMAT field")
    expect_raises(HTS::Bcf::FormatTypeError) { format.with_f32_buffer("PL") { } }
  end

  def test_format_flag_is_unsupported
    header = HTS::Bcf::Header.new
    header.version = "VCFv4.3"
    header.append("##contig=<ID=1,length=100>")
    header.append("##FORMAT=<ID=BAD,Number=0,Type=Flag,Description=\"Unsupported\">")
    header.add_sample("S1")

    (header.format_type("BAD")).should eq(:flag)

    record = HTS::Bcf::Record.new(header)
    record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
    record.pos = 0
    format = record.format

    ex = expect_raises(HTS::Bcf::UnsupportedFormatOperationError) { format.get_string("BAD") }
    (ex.message).should eq("FORMAT flag fields are not supported: BAD")
  end

  def test_update_methods_round_trip
    with_temp_format_source_vcf do |source_path|
      with_temp_output_vcf do |output_path|
        HTS::Bcf.open(source_path) do |input_bcf|
          record = input_bcf.first
          format = record.format

          format.update_int("GQ", [11, 22])
          format.update_float("TF", [1.25_f32, 2.75_f32])
          format.update_string("ST", ["LEFT", "RIGHT"])
          format.update_genotypes([
            HTS::LibHTS2.bcf_gt_unphased(0),
            HTS::LibHTS2.bcf_gt_unphased(0),
            HTS::LibHTS2.bcf_gt_phased(1),
            HTS::LibHTS2.bcf_gt_phased(1),
          ])

          HTS::Bcf.open(output_path, "w") do |output_bcf|
            output_bcf.write_header(input_bcf.header)
            output_bcf << record
          end
        end

        HTS::Bcf.open(output_path) do |verify_bcf|
          format = verify_bcf.first.format

          (format.get_int("GQ")).should eq([11, 22])
          (format.get_string("ST")).should eq(["LEFT", "RIGHT"])
          (format.get_string("GT")).should eq(["0/0", "1|1"])

          floats = format.get_float("TF") || raise "TF should be present"
          (floats.size).should eq(2)
          ((floats[0]) - (1.25_f32)).abs.should be <= 0.001
          ((floats[1]) - (2.75_f32)).abs.should be <= 0.001
        end
      end
    end
  end

  def test_delete_round_trip
    with_temp_format_source_vcf do |source_path|
      with_temp_output_vcf do |output_path|
        HTS::Bcf.open(source_path) do |input_bcf|
          record = input_bcf.first
          format = record.format

          (format.delete("ST")).should be_true
          (format.delete("ST")).should be_false

          HTS::Bcf.open(output_path, "w") do |output_bcf|
            output_bcf.write_header(input_bcf.header)
            output_bcf << record
          end
        end

        HTS::Bcf.open(output_path) do |verify_bcf|
          (verify_bcf.first.format.get_string("ST")).should be_nil
        end
      end
    end
  end

  def test_update_values_not_divisible_by_samples
    with_temp_format_source_vcf do |source_path|
      HTS::Bcf.open(source_path) do |bcf|
        format = bcf.first.format

        ex = expect_raises(HTS::Bcf::FormatUpdateError) { format.update_int("GQ", [1, 2, 3]) }
        (ex.message).should eq("FORMAT values for GQ must be divisible by sample count (2)")
      end
    end
  end

  def test_update_string_requires_one_value_per_sample
    with_temp_format_source_vcf do |source_path|
      HTS::Bcf.open(source_path) do |bcf|
        format = bcf.first.format

        ex = expect_raises(HTS::Bcf::FormatUpdateError) { format.update_string("ST", "solo") }
        (ex.message).should eq("FORMAT string values for ST must provide one entry per sample (2)")
      end
    end
  end
end

describe BcfFormatTest do
  {% for method in BcfFormatTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfFormatTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
