require "../src/hts"

# Simple pileup example
bam = HTS::Bam.open("test/fixtures/moo.bam")

puts "=== Single BAM Pileup Example ==="
puts

# Create pileup iterator with filter
iter = HTS::Pileup::Iterator.with_filter(bam) do |record|
  next false if record.flag.unmapped?
  next false if record.flag.secondary?
  next false if record.mapq < 20
  true
end

iter.max_depth = 8000

# Count bases at each position
count = 0
iter.each do |result|
  tid, pos, alignments = result
  
  # Get reference name
  ref_name = bam.header.tid2name(tid)
  
  # Count bases
  bases = Hash(Char, Int32).new(0)
  total_qual = 0
  
  alignments.each do |aln|
    next if aln.is_del || aln.is_refskip
    
    if base = aln.base?
      bases[base] += 1
      total_qual += aln.base_quality
    end
  end
  
  if bases.size > 0
    avg_qual = total_qual / alignments.size
    puts "#{ref_name}:#{pos + 1}\tdepth=#{alignments.size}\tqual=#{avg_qual}\t#{bases}"
  end
  
  count += 1
  break if count >= 20  # Show first 20 positions
end

iter.close
bam.close

puts
puts "=== Multi-BAM Pileup Example ==="
puts

# Multi-file pileup
bam1 = HTS::Bam.open("test/fixtures/moo.bam")
bam2 = HTS::Bam.open("test/fixtures/poo.sort.bam")

bams = [bam1, bam2]

multi_iter = HTS::Pileup::MultiIterator.with_filter(bams) do |record|
  !record.flag.unmapped?
end

multi_iter.max_depth = 8000
multi_iter.overlap_detection = true

count = 0
multi_iter.each do |result|
  tid, pos, samples = result
  
  ref_name = bam1.header.tid2name(tid)
  
  depths = samples.map(&.size)
  puts "#{ref_name}:#{pos + 1}\tdepths=#{depths}"
  
  count += 1
  break if count >= 10
end

multi_iter.close
bam1.close
bam2.close

puts
puts "Done!"
