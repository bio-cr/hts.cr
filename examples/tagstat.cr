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
  property? distinct_overflow : Bool

  def initialize(@tag : String, @type : String)
    @reads = 0_i64
    @examples = [] of String
    @example_keys = Set(String).new
    @distinct_values = Set(String).new
    @distinct_overflow = false
  end

  def add(value, example_limit : Int32, distinct_limit : Int32)
    @reads += 1

    example = TagStatValue.example(value)
    if @examples.size < example_limit && !@example_keys.includes?(example)
      @examples << example
      @example_keys << example
    end

    return if @distinct_overflow

    @distinct_values << TagStatValue.distinct_key(value)
    if @distinct_values.size > distinct_limit
      @distinct_values.clear
      @distinct_overflow = true
    end
  end
end

module TagStatValue
  extend self

  def example(value) : String
    case value
    when Array
      "len=#{value.size}"
    when String
      string_preview(value)
    else
      value.to_s
    end
  end

  def distinct_key(value) : String
    case value
    when Array
      value.join(",")
    else
      value.to_s
    end
  end

  private def string_preview(value : String) : String
    indexes = [
      value.index(','),
      value.index('\t'),
      value.index(';'),
    ].compact
    preview = indexes.empty? ? value : value[0, indexes.min]
    preview = value if preview.empty? && !value.empty?
    preview.size > 40 ? "#{preview[0, 37]}..." : preview
  end
end

class TagStatOptions
  property? json_output : Bool = false
  property example_limit : Int32 = 3
  property distinct_limit : Int32 = 10_000
  property threads : Int32 = 0
  property input : String?
end

def parse_options : TagStatOptions
  options = TagStatOptions.new

  parser = OptionParser.parse do |parser_config|
    parser_config.banner = "Usage: tagstat [options] <in.bam|in.cram>"
    parser_config.on("--json", "Output JSON instead of TSV") { options.json_output = true }
    parser_config.on("--limit N", "Maximum number of examples per tag/type (default: #{options.example_limit})") { |value| options.example_limit = value.to_i }
    parser_config.on("--distinct-limit N", "Maximum distinct values to track exactly (default: #{options.distinct_limit})") { |value| options.distinct_limit = value.to_i }
    parser_config.on("-t N", "--threads N", "Number of threads for BAM/CRAM decoding") { |value| options.threads = value.to_i }
    parser_config.on("-h", "--help", "Show help") { puts parser_config; exit 0 }
  end

  if ARGV.size != 1
    STDERR.puts parser
    abort "ERROR: Specify one input BAM/CRAM file."
  end

  options.input = ARGV[0]
  options
end

def validate_options!(options : TagStatOptions)
  abort "ERROR: --limit must be >= 0" if options.example_limit < 0
  abort "ERROR: --distinct-limit must be >= 0" if options.distinct_limit < 0
  abort "ERROR: --threads must be >= 0" if options.threads < 0
end

def collect_tag_stats(input : String, options : TagStatOptions) : {Int64, Array(TagStatEntry)}
  total_reads = 0_i64
  stats = Hash(Tuple(String, String), TagStatEntry).new do |hash, key|
    hash[key] = TagStatEntry.new(key[0], key[1])
  end

  HTS::Bam.open(input, threads: options.threads) do |bam|
    bam.each do |record|
      total_reads += 1

      record.aux.each_with_type do |tag, type, value|
        stats[{tag, type}].add(value, options.example_limit, options.distinct_limit)
      end
    end
  end

  rows = stats.values.sort_by! { |stat| {-stat.reads, stat.tag, stat.type} }
  {total_reads, rows}
end

def write_json(total_reads : Int64, rows : Array(TagStatEntry), distinct_limit : Int32)
  json_text = JSON.build(indent: "  ") do |json|
    json.object do
      json.field "total_reads", total_reads
      json.field "tags" do
        json.array do
          rows.each do |row|
            json.object do
              json.field "tag", row.tag
              json.field "type", row.type
              json.field "reads", row.reads
              json.field "percent", percent(row.reads, total_reads).round(1)
              json.field "distinct", row.distinct_overflow? ? ">#{distinct_limit}" : row.distinct_values.size
              json.field "examples", row.examples
            end
          end
        end
      end
    end
  end
  puts json_text
end

def write_tsv(total_reads : Int64, rows : Array(TagStatEntry), distinct_limit : Int32)
  puts %w[tag type reads percent distinct examples].join('\t')
  rows.each do |row|
    distinct = row.distinct_overflow? ? ">#{distinct_limit}" : row.distinct_values.size.to_s
    puts [
      row.tag,
      row.type,
      row.reads.to_s,
      "%.1f" % percent(row.reads, total_reads),
      distinct,
      row.examples.join(","),
    ].join('\t')
  end
end

def percent(reads : Int64, total_reads : Int64) : Float64
  total_reads.zero? ? 0.0 : (reads * 100.0 / total_reads)
end

options = parse_options
validate_options!(options)
input = options.input || abort "ERROR: Specify one input BAM/CRAM file."
total_reads, rows = collect_tag_stats(input, options)

if options.json_output?
  write_json(total_reads, rows, options.distinct_limit)
else
  write_tsv(total_reads, rows, options.distinct_limit)
end
