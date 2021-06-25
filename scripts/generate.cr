Dir.cd(__DIR__) do
  system "crystal build convert.cr"
  Dir["../htslib/htslib/*.h"].each do |h|
    puts h
    basename = File.basename(h, ".h")
    system "mkdir -p json"
    system "c2ffi #{h} > json/#{basename}.json"
    system "./convert json/#{basename}.json > json/#{basename}.cr"
  end
  system "rm convert"
end
