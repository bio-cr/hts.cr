require "spec"
require "../src/hts"

class HTSSpecCase
  def setup
  end

  def teardown
  end
end

def run_spec_case(spec_case : HTSSpecCase, &)
  spec_case.setup
  begin
    yield
  ensure
    spec_case.teardown
  end
end

def expect_equal(expected, actual)
  actual.should eq expected
end

def expect_true(actual, message = nil)
  actual.should be_true
end

def expect_false(actual)
  actual.should be_false
end

def expect_nil(actual)
  actual.should be_nil
end

def expect_not_nil(actual)
  actual.should_not be_nil
end

def expect_instance_of(klass : T.class, actual) forall T
  actual.is_a?(T).should be_true
end

def expect_includes(collection, value)
  (collection.nil? ? false : collection.includes?(value)).should be_true
end

def expect_same(expected, actual)
  actual.same?(expected).should be_true
end

def expect_in_delta(expected, actual, delta)
  (actual - expected).abs.should be <= delta
end

def expect_raises(&)
  expect_raises(Exception) { yield }
end

BAM_FLAG_METHODS = %w[
  paired?
  proper_pair?
  unmapped?
  mate_unmapped?
  reverse?
  mate_reverse?
  read1?
  read2?
  secondary?
  qcfail?
  duplicate?
  supplementary?
]

module TestBcfMultisampleHelper
  def with_temp_multisample_bcf(&)
    file = File.tempfile("multisample_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.set_version("VCFv4.3")
      header.append("##contig=<ID=1,length=100>")
      header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
      header.add_sample("A", sync: false)
      header.add_sample("B", sync: true)

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        genotypes = [
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(0),
          HTS::LibHTS2.bcf_gt_unphased(1),
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
end
