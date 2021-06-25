# frozen_string_literal: true

# This is a ruby script to convert a C header json file to crystal code.
# Please use c2ffi https://github.com/rpav/c2ffi to generate json files
# from C headers before running this script.

require "json"

class Converter
  TYPE_TABLE = {
    ":int"                => "Int32",
    ":unsigned-int"       => "UInt32",
    "int64_t"             => "Int64",
    "__uint8_t"           => "UInt8",
    "__uint16_t"          => "UInt16",
    "__uint32_t"          => "UInt32",
    "__uint64_t"          => "UInt64",
    "int8_t"              => "Int8",
    "int16_t"             => "Int16",
    "int32_t"             => "Int32",
    "int64_t"             => "Int64",
    "uint8_t"             => "UInt8",
    "uint16_t"            => "UInt16",
    "uint32_t"            => "UInt32",
    "uint64_t"            => "UInt64",
    ":float"              => "Float32",
    ":double"             => "Float64",
    ":short"              => "Short",
    ":unsigned-short"     => "UShort",
    ":long"               => "Long",
    ":unsigned-long"      => "ULong",
    ":long-long"          => "LongLong",
    ":unsigned-long-long" => "ULongLong",
    ":char"               => "LibC::Char",
    ":signed-char"        => "Int8",
    "size_t"              => "SizeT",
    "ssize_t"             => "SSizeT",
    "__ssize_t"           => "SSizeT",
    ":void"               => "Void",
  }

  def initialize(json_path)
    json_path = File.expand_path(json_path)
    @unknown = Array(Array(String)).new
    @error_flag = false
    json_text = File.read(json_path)
    metadata = JSON.parse(json_text)

    structs = filter_structs(metadata)
    puts convert_structs(structs).join("\n")

    functions = filter_functions(metadata)
    puts convert_functions(functions).join("\n")

    puts unknown_types_info
  end

  def crystal_type(str, fname)
    type = TYPE_TABLE[str]?
    if type.nil?
      @unknown << [fname.to_s, str.to_s]
      @error_flag = true
      type = ""
    end
    type
  end

  def filter_structs(metadata)
    metadata.as_a.select { |v| v["tag"] == "struct" }.map { |v| v.as_h }
  end

  def filter_functions(metadata)
    metadata.as_a.select { |v| v["tag"] == "function" }.map { |v| v.as_h }
  end

  def convert_structs(structs)
    structs.map do |struct_hash|
      struct_to_string(struct_hash)
    end
  end

  def convert_functions(functions)
    functions.map do |func_hash|
      function_to_string(func_hash)
    end
  end

  def struct_to_string(sh)
    name = sh["name"].to_s

    if name.starts_with?("_")
      return nil
    end

    str = "struct " + name.camelcase + "\n"
    sh["fields"].as_a.each do |field|
      str += "  #{field["name"]} : "
      str += parse_parameters(field, name)
      str += "\n"
    end
    str += "end\n"
  end

  def function_to_string(fh)
    name = fh["name"].to_s
    str = "fun #{name}("

    # parameter types
    fh["parameters"].as_a.each_with_index do |param, idx|
      # add ,
      unless idx == 0
        str += ", "
      end
      str += parse_parameters(param, name)
    end

    str += ") : "

    # return types
    if fh.dig("return-type", "tag") == ":pointer"
      str += crystal_type(fh["return-type"]["type"]["tag"], name)
      str += "*"
    else
      str += crystal_type(fh["return-type"]["tag"], name)
    end

    # commment out if error
    if @error_flag
      @error_flag = false
      "# " + str
    else
      str
    end
  end

  def parse_parameters(param, name)
    str = ""
    type_1 = param["type"]
    # not pointer
    unless type_1["tag"] == ":pointer"
      str += crystal_type(type_1["tag"], name)
      # pointer
    else
      type_2 = type_1["type"]
      # not pointer of pointer
      unless type_2["tag"] == ":pointer"
        str += crystal_type(type_2["tag"], name)
        str += "*"
        # pointer of pointer
      else
        str += crystal_type(type_2.dig("type", "tag"), name)
        str += "**"
      end
    end
    str
  end

  def unknown_types_info
    str = "\n" + "# Unknown types\n" +
          "# #{@unknown.map { |i| i[1] }.uniq}\n"
    @unknown.each do |i|
      str += "# #{i.join(", ")}\n"
    end
    str
  end
end

Converter.new(ARGV[0])
