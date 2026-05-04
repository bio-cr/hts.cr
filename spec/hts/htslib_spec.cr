require "../spec_helper"
require "../../src/hts/libhts.cr"

class HTSTest
  def test_version
    (HTS::VERSION).should be_a(String)
  end

  def test_hts_version
    (String.new(HTS::LibHTS.hts_version)).should be_a(String)
  end
end

describe HTSTest do
  {% for method in HTSTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = HTSTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
