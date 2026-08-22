require "../spec_helper"
require "../../src/hts/libhts.cr"

class HTSTest
  def test_version
    (HTS::VERSION).should be_a(String)
  end

  def test_hts_version
    (String.new(HTS::LibHTS.hts_version)).should be_a(String)
  end

  def test_hfile_bitfield_layout_and_accessors
    offsetof(HTS::LibHTS::HFile, @has_errno).should eq(
      offsetof(HTS::LibHTS::HFile, @bitfields) + sizeof(LibC::UInt)
    )

    hfile = HTS::LibHTS::HFile.new
    hfile.bitfields = HTS::LibHTS2::HFILE_AT_EOF | HTS::LibHTS2::HFILE_MOBILE | HTS::LibHTS2::HFILE_PRESERVE
    pointer = pointerof(hfile)

    HTS::LibHTS2.hfile_at_eof?(pointer).should be_true
    HTS::LibHTS2.hfile_mobile?(pointer).should be_true
    HTS::LibHTS2.hfile_readonly?(pointer).should be_false
    HTS::LibHTS2.hfile_preserve?(pointer).should be_true
  end
end

describe HTSTest do
  {% for method in HTSTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = HTSTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
