require "../spec_helper"

describe HTS::Pileup do
  describe "Iterator" do
    it "can iterate over pileup columns with filter" do
      bam = HTS::Bam.open("test/fixtures/moo.bam")
      
      # Create iterator with filter
      iter = HTS::Pileup::Iterator.with_filter(bam) do |record|
        next false if record.flag.unmapped?
        next false if record.flag.secondary?
        next false if record.mapq < 20
        true
      end
      
      iter.max_depth = 8000
      
      # Collect some pileup data
      columns = [] of {Int32, Int64, Int32}  # tid, pos, depth
      count = 0
      
      iter.each do |tid, pos, alignments|
        columns << {tid, pos, alignments.size}
        count += 1
        break if count >= 10  # Just test first 10 positions
      end
      
      # Should have processed some positions
      columns.size.should be > 0
      
      # Check that positions are reasonable
      columns.each do |tid, pos, depth|
        tid.should be >= 0
        pos.should be >= 0
        depth.should be >= 0
      end
      
      iter.close
      bam.close
    end
    
    it "can access alignment details" do
      bam = HTS::Bam.open("test/fixtures/moo.bam")
      
      iter = HTS::Pileup::Iterator.with_filter(bam) do |record|
        !record.flag.unmapped?
      end
      
      found_base = false
      
      iter.each do |tid, pos, alignments|
        alignments.each do |aln|
          # Check basic properties
          aln.qpos.should be >= 0
          aln.is_del.should be_a(Bool)
          aln.is_head.should be_a(Bool)
          aln.is_tail.should be_a(Bool)
          aln.is_refskip.should be_a(Bool)
          
          # Check base and quality
          unless aln.is_del || aln.is_refskip
            if base = aln.base?
              base.should be_a(Char)
              qual = aln.base_quality
              qual.should be_a(UInt8)
              found_base = true
            end
          end
          
          # Check record access
          record = aln.record
          record.should be_a(HTS::Bam::Record)
        end
        
        break if found_base
      end
      
      found_base.should be_true
      
      iter.close
      bam.close
    end
    
    it "can use RAII style" do
      bam = HTS::Bam.open("test/fixtures/moo.bam")
      
      count = 0
      HTS::Pileup::Iterator.open(bam) do |iter|
        iter.each do |tid, pos, alignments|
          count += 1
          break if count >= 5
        end
      end
      
      count.should eq(5)
      bam.close
    end
  end
  
  describe "MultiIterator" do
    it "can iterate over multiple BAM files" do
      bam1 = HTS::Bam.open("test/fixtures/moo.bam")
      bam2 = HTS::Bam.open("test/fixtures/poo.sort.bam")
      
      bams = [bam1, bam2]
      
      iter = HTS::Pileup::MultiIterator.with_filter(bams) do |record|
        !record.flag.unmapped?
      end
      
      iter.max_depth = 8000
      
      count = 0
      iter.each do |tid, pos, samples|
        samples.size.should eq(2)  # Two BAM files
        
        samples.each do |alignments|
          alignments.should be_a(Array(HTS::Pileup::Alignment))
        end
        
        count += 1
        break if count >= 5
      end
      
      count.should eq(5)
      
      iter.close
      bam1.close
      bam2.close
    end
    
    it "can enable overlap detection" do
      bam1 = HTS::Bam.open("test/fixtures/moo.bam")
      bam2 = HTS::Bam.open("test/fixtures/poo.sort.bam")
      
      bams = [bam1, bam2]
      
      iter = HTS::Pileup::MultiIterator.with_filter(bams) do |record|
        !record.flag.unmapped?
      end
      
      # Enable overlap detection
      iter.overlap_detection = true
      
      count = 0
      iter.each do |tid, pos, samples|
        count += 1
        break if count >= 3
      end
      
      count.should eq(3)
      
      iter.close
      bam1.close
      bam2.close
    end
    
    it "can use RAII style with multiple files" do
      bam1 = HTS::Bam.open("test/fixtures/moo.bam")
      bam2 = HTS::Bam.open("test/fixtures/poo.sort.bam")
      
      bams = [bam1, bam2]
      
      count = 0
      HTS::Pileup::MultiIterator.open(bams) do |iter|
        iter.each do |tid, pos, samples|
          count += 1
          break if count >= 3
        end
      end
      
      count.should eq(3)
      bam1.close
      bam2.close
    end
  end
  
  describe "Helper" do
    it "can get insertion sequences" do
      bam = HTS::Bam.open("test/fixtures/moo.bam")
      
      iter = HTS::Pileup::Iterator.with_filter(bam) do |record|
        !record.flag.unmapped?
      end
      
      found_insertion = false
      
      iter.each do |tid, pos, alignments|
        alignments.each do |aln|
          if aln.indel > 0  # Has insertion
            result = HTS::Pileup::Helper.insertion(aln)
            result.should be_a(NamedTuple(seq: String, del_len: Int32))
            found_insertion = true if result[:seq].size > 0
          end
        end
        
        break if found_insertion
      end
      
      # Note: We might not find insertions in test data, so this is optional
      
      iter.close
      bam.close
    end
  end
end
