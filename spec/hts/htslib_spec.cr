require "../spec_helper"
require "../../src/hts/libhts.cr"

class HTSTest < HTSSpecCase
  def test_version
    expect_instance_of String, HTS::VERSION
  end

  def test_hts_version
    expect_instance_of String, String.new(HTS::LibHTS.hts_version)
  end
end

describe HTSTest do
  {% for method in HTSTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = HTSTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
