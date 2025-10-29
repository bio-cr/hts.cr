require "../src/hts"

# Example: Reading base modifications (MM/ML tags) from SAM/BAM/CRAM files
#
# Usage:
#   crystal run examples/base_mod.cr -- [input.bam]
#
# Without arguments, uses a public test file with base modifications from htslib.

DEFAULT_URL = "https://raw.githubusercontent.com/samtools/htslib/refs/heads/develop/test/base_mods/MM-chebi.sam"

input_path = ARGV[0]? || DEFAULT_URL

HTS::Bam.open(input_path) do |bam|
  bam.each do |record|
    puts "Record: #{record.qname}"
    puts "Sequence: #{record.seq}"

    base_mod = record.base_mod

    # Check what modification types are present
    mod_types = base_mod.recorded_types
    if mod_types.empty?
      puts "No modifications found"
      puts
      next
    end

    puts "Modification types:"
    mod_types.each do |code|
      info = base_mod.query_type(code)
      type_name = code > 0 ? code.chr.to_s : "ChEBI:#{-code}"
      if info
        canonical = info[:canonical]
        strand = info[:strand]
        puts "  #{type_name} on #{canonical} (strand: #{strand})"
      else
        puts "  #{type_name} (no metadata)"
      end
    end

    # Iterate through all modified positions
    puts "Modified positions:"
    base_mod.each do |position|
      print "  pos #{position.position}: "
      position.modifications.each do |mod|
        code_str = mod.code
        prob = mod.probability
        if prob
          print "#{mod.canonical}->#{code_str} (#{(prob * 100).round(1)}%) "
        else
          print "#{mod.canonical}->#{code_str} "
        end
      end
      puts
    end

    # Show convenience methods
    if base_mod.any?(&.methylated?)
      methylated_positions = base_mod.select(&.methylated?).map(&.position)
      puts "Methylated (m) at: #{methylated_positions.join(", ")}"
    end

    # Example: Random access to specific position
    if first_mod = base_mod.first?
      example_pos = first_mod.position
      if mod_at_pos = base_mod.at_pos(example_pos)
        codes = mod_at_pos.modifications.map(&.code).join(", ")
        puts "Random access at_pos(#{example_pos}): #{codes}"
      end
    end

    puts
  end
end
