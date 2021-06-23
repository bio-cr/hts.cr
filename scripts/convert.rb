# frozen_string_literal: true

# This is a ruby script to convert a C header json file to crystal code.
# Please use c2ffi https://github.com/rpav/c2ffi to generate json files
# from C headers before running this script.

require 'json'

TYPE_TABLE = {
  ':int' => 'Int32',
  ':unsigned-int' => 'UInt32',
  'int64_t' => 'Int64',
  '__uint8_t' => 'UInt8',
  '__uint16_t' => 'UInt16',
  '__uint32_t' => 'UInt32',
  '__uint64_t' => 'UInt64',
  'int8_t' => 'Int8',
  'int16_t' => 'Int16',
  'int32_t' => 'Int32',
  'int64_t' => 'Int64',
  'uint8_t' => 'UInt8',
  'uint16_t' => 'UInt16',
  'uint32_t' => 'UInt32',
  'uint64_t' => 'UInt64',
  ':float' => 'Float32',
  ':double' => 'Float64',
  ':short' => 'Short',
  ':unsigned-short' => 'UShort',
  ':long' => 'Long',
  ':unsigned-long' => 'ULong',
  ':long-long' => 'LongLong',
  ':unsigned-long-long' => 'ULongLong',
  ':char' => 'UInt8',
  ':signed-char' => 'Int8',
  'size_t' => 'SizeT',
  'ssize_t' => 'SSizeT',
  '__ssize_t' => 'SSizeT',
  ':void' => 'Void'
}.freeze

def camel(str)
  str.split(/_/).map do |w|
    next if w[0].nil?
    w[0] = w[0].upcase
    w 
  end.join
end

def snake(str)
  str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
     .gsub(/([a-z\d])([A-Z])/, '\1_\2')
     .downcase
end

@unknown = []
@error_flag = false

def crystal_type(str, fname)
  type = TYPE_TABLE[str]
  if type.nil?
    @unknown << [fname, str, caller.first] if type.nil?
    @error_flag = true
    type = ''
  end
  type
end

data = JSON.parse(ARGF.read)

# struct
structs = data.filter { |d| d['tag'] == 'struct' }
structs.each do |s|
  str = String.new('')
  str << "struct "
  str << camel(s['name'])
  str << "\n"
  s['fields'].each do |field|
    str << "  #{field['name']} : "
    str << crystal_type(field['type']&.[]('tag'), s['name']) << "\n"
  end
  str << "end"
  puts str
  puts
end

# functions
funcs = data.filter { |d| d['tag'] == 'function' }
funcs.each do |f|
  str = String.new('')
  str << 'fun '
  str << f['name']
  str << '('
  f['parameters'].each_with_index do |prm, idx|
    idx.zero? || str << (', ')
    if prm['type']['tag'] == ':pointer'
      if prm['type']['type']['tag'] == ':pointer'
        str << crystal_type(prm['type']['type']['type']['tag'], f['name'])
        str << '*'
      else
        str << crystal_type(prm['type']['type']['tag'], f['name'])
      end
      str << '*'
    else
      str << crystal_type(prm['type']['tag'], f['name'])
    end
  end
  str << ') : '
  if f['return-type']['tag'] == ':pointer'
    str << crystal_type(f['return-type']['type']['tag'], f[:name])
    str << '*'
  else
    str << crystal_type(f['return-type']['tag'], f['name'])
  end
  print '# ' if @error_flag
  @error_flag = false
  puts str
end

puts
puts '# Unknow types'
puts "# #{@unknown.map { |i| i[1] }.uniq}"
puts '# caller'
@unknown.each do |i|
  puts "# #{i.join(', ')}"
end

