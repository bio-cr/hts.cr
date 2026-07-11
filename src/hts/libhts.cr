require "./version"
require "./error"

# LibHTS
require "./libhts/libhts"

# LibHTS2

module HTS
  module LibHTS2
    macro alias_method(new_name, old_name)
      def {{ new_name.id }}(*args)
        LibHTS.{{ old_name.id }}(*args)
      end
    end

    macro htslib_at_least(major, minor, patch = 0, &block)
      {% raw_version = `pkg-config --modversion htslib`.strip %}
      {% if raw_version.empty? %}
        {% raise "Unable to determine htslib version: `pkg-config --modversion htslib` returned an empty string" %}
      {% end %}
      {% parts = raw_version.split(/[.-]/) %}
      {% version = parts[0] + "." + (parts[1] || "0") + "." + (parts[2] || "0") %}
      {% required = major.stringify + "." + minor.stringify + "." + patch.stringify %}
      {% if compare_versions(version, required) >= 0 %}
        {{ block.body }}
      {% end %}
    end

    macro htslib_before(major, minor, patch = 0, &block)
      {% raw_version = `pkg-config --modversion htslib`.strip %}
      {% if raw_version.empty? %}
        {% raise "Unable to determine htslib version: `pkg-config --modversion htslib` returned an empty string" %}
      {% end %}
      {% parts = raw_version.split(/[.-]/) %}
      {% version = parts[0] + "." + (parts[1] || "0") + "." + (parts[2] || "0") %}
      {% required = major.stringify + "." + minor.stringify + "." + patch.stringify %}
      {% if compare_versions(version, required) < 0 %}
        {{ block.body }}
      {% end %}
    end
  end
end

require "./libhts2/hfile"
require "./libhts2/bgzf"
require "./libhts2/sam"
require "./libhts2/tbx"
require "./libhts2/vcf"
