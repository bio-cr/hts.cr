# frozen_string_literal: true

# This is a ruby script to convert a C header json file to crystal code.
# Please use c2ffi https://github.com/rpav/c2ffi to generate json files
# from C headers before running this script.

require 'json'

TYPE_TABLE = {
  ':int' => 'Int32',
  ':unsigned-int' => 'UInt32',
  ':float' => 'Float32',
  ':double' => 'Float64',
  ':unsigned-short' => 'UShort',
  ':long' => 'Long',
  ':unsigned-long' => 'ULong',
  ':long-long' => 'LongLong',
  ':unsigned-long-long' => 'ULongLong',
  ':char' => 'UInt8',
  'size_t' => 'SizeT',
  ':void' => 'Void'
}.freeze

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

data = JSON.parse(File.read(ARGV[0]))

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

