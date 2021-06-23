Dir.cd(__DIR__) do
  Dir["../htslib/htslib/*.h"].each do |h|
    basename = File.basename(h, ".h")
    system "mkdir -p json"
    system "c2ffi #{h} > json/#{basename}.json"
    system "ruby convert.rb json/#{basename}.json > json/#{basename}.cr"
  end
end