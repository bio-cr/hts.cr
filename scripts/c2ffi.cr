Dir.cd(__DIR__) do
  Dir["../htslib/htslib/*.h"].each do |h|
    basename = File.basename(h, ".h")
    system "c2ffi #{h} > #{basename}.json"
    system "ruby convert.rb #{basename}.json > #{basename}.cr"
  end
end