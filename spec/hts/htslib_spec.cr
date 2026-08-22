require "../spec_helper"
require "../../src/hts/libhts.cr"

class HTSTest
  def test_version
    (HTS::VERSION).should be_a(String)
  end

  def test_hts_version
    (String.new(HTS::LibHTS.hts_version)).should be_a(String)
  end

  def test_hfile_bitfield_layout
    offsetof(HTS::LibHTS::HFile, @has_errno).should eq(
      offsetof(HTS::LibHTS::HFile, @bitfields) + sizeof(LibC::UInt)
    )
  end

  def test_hfile_layout_supports_inline_htell
    file = File.tempfile("hfile_layout")
    path = file.path
    file << "abcdef"
    file.close

    hfile = HTS::LibHTS.hopen(path, "r")
    hfile.null?.should be_false
    HTS::LibHTS2.htell(hfile).should eq(0)

    HTS::LibHTS.hseek(hfile, 3, IO::Seek::Set).should eq(3)
    HTS::LibHTS2.htell(hfile).should eq(3)
  ensure
    HTS::LibHTS.hclose(hfile) if hfile && !hfile.null?
    File.delete(path) if path && File.exists?(path)
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
