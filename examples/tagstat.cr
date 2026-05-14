require "json"
require "option_parser"
require "set"
require "../src/hts"

# Usage:
#   crystal run examples/tagstat.cr -- [options] input.bam

class TagStatEntry
  getter tag : String
  getter type : String
  property reads : Int64
  getter examples : Array(String)
  getter example_keys : Set(String)
  getter distinct_values : Set(String)
  property distinct_overflow : Bool

  def initialize(@tag : String, @type : String)
    @reads = 0_i64
    @examples = [] of String
    @example_keys = Set(String).new
    @distinct_values = Set(String).new
    @distinct_overflow = false
  end
end

json_output = false
limit = 3
distinct_limit = 10_000
threads = 0

parser = OptionParser.parse do |p|
  p.banner = "Usage: tagstat [options] <in.bam|in.cram>"
  p.on("--json", "Output JSON instead of TSV") { json_output = true }
  p.on("--limit N", "Maximum number of examples per tag/type (default: #{limit})") { |v| limit = v.to_i }
  p.on("--distinct-limit N", "Maximum distinct values to track exactly (default: #{distinct_limit})") { |v| distinct_limit = v.to_i }
  p.on("-t N", "--threads N", "Number of threads for BAM/CRAM decoding") { |v| threads = v.to_i }
  p.on("-h", "--help", "Show help") { puts p; exit 0 }
end

if ARGV.size != 1
  STDERR.puts parser
  abort "ERROR: Specify one input BAM/CRAM file."
end

abort "ERROR: --limit must be >= 0" if limit < 0
abort "ERROR: --distinct-limit must be >= 0" if distinct_limit < 0
abort "ERROR: --threads must be >= 0" if threads < 0

input = ARGV[0]
stats = Hash(Tuple(String, String), TagStatEntry).new do |hash, key|
  hash[key] = TagStatEntry.new(key[0], key[1])
end

def string_preview(value : String) : String
  indexes = [
    value.index(','),
    value.index('\t'),
    value.index(';'),
  ].compact
  preview = indexes.empty? ? value : value[0, indexes.min]
  preview = value if preview.empty? && !value.empty?
  preview.size > 40 ? "#{preview[0, 37]}..." : preview
end

def formatted_example(value : HTS::Bam::AuxValue) : String
  case value
  when Array
    "len=#{value.size}"
  when String
    string_preview(value)
  else
    value.to_s
  end
end

def distinct_value_key(value : HTS::Bam::AuxValue) : String
  case value
  when Array
    value.join(",")
  else
    value.to_s
  end
end

total_reads = 0_i64

HTS::Bam.open(input, threads: threads) do |bam|
  bam.each do |record|
    total_reads += 1

    record.aux.each_with_type do |tag, type, value|
      stat = stats[{tag, type}]
      stat.reads += 1

      example = formatted_example(value)
      if stat.examples.size < limit && !stat.example_keys.includes?(example)
        stat.examples << example
        stat.example_keys << example
      end

      next if stat.distinct_overflow

      distinct_key = distinct_value_key(value)
      stat.distinct_values << distinct_key
      if stat.distinct_values.size > distinct_limit
        stat.distinct_values.clear
        stat.distinct_overflow = true
      end
    end
  end
end

rows = stats.values.sort_by { |stat| {-stat.reads, stat.tag, stat.type} }

if json_output
  puts JSON.build(indent: "  ") { |json|
    json.object do
      json.field "total_reads", total_reads
      json.field "tags" do
        json.array do
          rows.each do |row|
            json.object do
              json.field "tag", row.tag
              json.field "type", row.type
              json.field "reads", row.reads
              json.field "percent", total_reads.zero? ? 0.0 : (row.reads * 100.0 / total_reads).round(1)
              json.field "distinct", row.distinct_overflow ? ">#{distinct_limit}" : row.distinct_values.size
              json.field "examples", row.examples
            end
          end
        end
      end
    end
  }
else
  puts %w[tag type reads percent distinct examples].join('\t')
  rows.each do |row|
    percent = total_reads.zero? ? 0.0 : (row.reads * 100.0 / total_reads)
    distinct = row.distinct_overflow ? ">#{distinct_limit}" : row.distinct_values.size.to_s
    puts [
      row.tag,
      row.type,
      row.reads.to_s,
      "%.1f" % percent,
      distinct,
      row.examples.join(","),
    ].join('\t')
  end
end
