require "../spec_helper"
require "../../src/hts/bam"

class BamTest
  def teardown
    # close files
    {% for format in ["bam", "sam", "cram"] %}
      {% for type in ["string", "path", "uri"] %}
        @{{ format.id }}_{{ type.id }}.try &.close
      {% end %}
    {% end %}

    # Clean up index files created during tests
    cleanup_index_files
  end

  private def cleanup_index_files
    index_files = [
      "moo.bam.bai",
      "moo.cram.crai",
      "poo.sort.bam.bai",
    ]

    index_files.each do |file|
      File.delete(file) if File.exists?(file)
    end
  end

  private def with_temp_indexable_bam(&)
    temp_file = File.tempfile("bam_build_index", ".bam")
    temp_path = temp_file.path || raise "tempfile path is nil"
    temp_file.close

    header_text = <<-HEADER
      @HD\tVN:1.6\tSO:coordinate
      @SQ\tSN:chr1\tLN:1000
      @SQ\tSN:chr2\tLN:2000
      HEADER
    header = HTS::Bam::Header.parse(header_text)

    HTS::Bam.open(temp_path, "wb") do |bam|
      bam.write_header(header)

      rec1 = HTS::Bam::Record.new(
        header,
        qname: "read1",
        flag: 0_u16,
        rname: "chr1",
        pos: 100_i64,
        mapq: 60_u8,
        cigar_str: "10M",
        seq: "ACGTACGTAC",
        qual: [30_u8] * 10
      )
      bam.write(rec1)

      rec2 = HTS::Bam::Record.new(
        header,
        qname: "read2",
        flag: 0_u16,
        rname: "chr2",
        pos: 341_i64,
        mapq: 40_u8,
        cigar_str: "20M",
        seq: "GGTTAAGCGGTTAAGCGGTT",
        qual: [25_u8] * 20
      )
      bam.write(rec2)

      rec3 = HTS::Bam::Record.new(
        header,
        qname: "read3",
        flag: 0_u16,
        rname: "chr2",
        pos: 658_i64,
        mapq: 40_u8,
        cigar_str: "20M",
        seq: "GGTTAAGCGGTTAAGCGGTT",
        qual: [25_u8] * 20
      )
      bam.write(rec3)
    end

    begin
      yield temp_path
    ensure
      File.delete(temp_path) if File.exists?(temp_path)
      index_path = "#{temp_path}.bai"
      File.delete(index_path) if File.exists?(index_path)
    end
  end

  {% for format in ["bam", "sam", "cram"] %}
    def path_{{ format.id }}_string
      File.expand_path("../fixtures/moo.{{ format.id }}", __DIR__)
    end

    def path_{{ format.id }}_path
      Path[path_{{ format.id }}_string]
    end

    def path_{{ format.id }}_uri
      "https://raw.githubusercontent.com/bio-cr/hts.cr/develop/spec/fixtures/moo.{{ format.id }}"
    end
  {% end %}

  {% for format in ["bam", "sam", "cram"] %}
    {% for type in ["string", "path", "uri"] %}
      {% ft = ("#{format.id}_#{type.id}").id %}
      def {{ ft }}
        @{{ ft }} ||= HTS::Bam.open(path_{{ ft }})
      end

      def test_new_{{ ft }}
        b = HTS::Bam.new(path_{{ ft }})
        (b).should be_a(HTS::Bam)
        b.close
        (b.closed?).should eq(true)
      end

      def test_open_{{ ft }}
        b = HTS::Bam.open(path_{{ ft }})
        (b).should be_a(HTS::Bam)
        (b.closed?).should eq(false)
        b.close
        (b.closed?).should eq(true)
        (b.close).should be_nil
      end

      def test_open_{{ ft }}_with_block
        result = HTS::Bam.open(path_{{ ft }}) do |b|
          (b).should be_a(HTS::Bam)
          :block_result
        end
        (result).should eq(:block_result)
      end

      {% if format == "bam" %}
      # FIXME: Cram dose not have cram_tell
      def test_tell_{{ ft }}
        ({{ ft }}.tell).should eq(21889024)
      end
      {% end %}

      {% if format == "sam" %}
      # FIXME: Cram dose not have cram_tell
      def test_tell_{{ ft }}
        ({{ ft }}.tell).should eq(134)
      end
      {% end %}

      def test_file_name_{{ ft }}
        ({{ ft }}.file_name).should eq(path_{{ ft }}.to_s)
      end

      def test_mode_{{ ft }}
        ({{ ft }}.mode).should eq("r")
      end

      def test_header_{{ ft }}
        ({{ ft }}.header).should be_a(HTS::Bam::Header)
      end

      def test_file_format_{{ ft }}
        ({{ ft }}.file_format).should eq({{ format }})
      end

      def test_file_format_version_{{ ft }}
        (["1", "1.6", "3.0"]).should contain({{ ft }}.file_format_version)
      end

      {% if format != "sam" %}
        def test_query_{{ ft }}
          arr = [] of Int64
          {{ ft }}.query("chr2:350-700") do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        def test_query_copy_{{ ft }}
          arr = [] of Int64
          {{ ft }}.query_copy("chr2:350-700") do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        # New: numeric tid query should produce identical positions.
        def test_query_tid_numeric_{{ ft }}
          arr = [] of Int64
          # Resolve tid from header (reference name to integer id)
          tid = {{ ft }}.header.get_tid("chr2")
          (tid >= 0).should be_true
          # Convert 1-based inclusive 350-700 to 0-based half-open => [349, 700)
          {{ ft }}.query(tid, 349_i64, 700_i64) do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        # New: chromosome name + numeric coordinates variant
        def test_query_chrom_numeric_{{ ft }}
          arr = [] of Int64
          # chr2, 350-700 uses 1-based inclusive coordinates like region strings.
          {{ ft }}.query("chr2", 350_i64, 700_i64) do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        def test_query_multi_regions_{{ ft }}
          arr = [] of Int64
          {{ ft }}.query(["chr1:100-200", "chr2:350-700"]) do |aln|
            arr << aln.pos
          end
          (arr).should contain(341)
          (arr).should contain(658)
        end

        def test_query_multi_regions_copy_{{ ft }}
          arr = [] of Int64
          {{ ft }}.query_copy(["chr1:100-200", "chr2:350-700"]) do |aln|
            arr << aln.pos
          end
          (arr).should contain(341)
          (arr).should contain(658)
        end

        def test_query_single_region_array_{{ ft }}
          arr = [] of Int64
          {{ ft }}.query(["chr2:350-700"]) do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end
      {% end %}

      def test_each_{{ ft }}
        c = 0
        {{ ft }}.each do |aln|
          c += 1
          (aln).should be_a(HTS::Bam::Record)
        end
        (c).should eq(10)
      end

      def test_each_copy_{{ ft }}
        c = 0
        {{ ft }}.each_copy do |aln|
          c += 1
          (aln).should be_a(HTS::Bam::Record)
        end
        (c).should eq(10)
      end

      def test_qname_{{ ft }}
        b = HTS::Bam.new(path_{{ ft }})
        {% if format == "cram" %}
        stderr = capture_stderr do
          (b.qname.size).should eq(10)
        end
        (stderr).should contain("not seekable")
        {% else %}
        (b.qname.size).should eq(10)
        {% end %}
        b.close
      end

    {% end %}
  {% end %}

  def test_initialize_no_file_bam
    with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
      expect_raises(HTS::Bam::OpenError) { HTS::Bam.new("/tmp/no_such_file") }
    end
  end

  def test_collection_helpers_keep_independent_records
    HTS::Bam.open(path_bam_string) do |bam|
      records = bam.map { |record| record }
      records.size.should eq(10)
      records[0].pos.should eq(178)
      records[2].pos.should eq(474)
      records[0].should_not be(records[1])

      bam.rewind
      first_two = bam.first(2)
      first_two.map(&.pos).should eq([178, 178])
      first_two[0].should_not be(first_two[1])
      bam.first?.try(&.pos).should eq(474)

      bam.rewind
      bam.first.pos.should eq(178)
      bam.rewind
      bam.first(0).should be_empty
      expect_raises(ArgumentError) { bam.first(-1) }
    end
  end

  def test_aux_from_mapped_records_keeps_native_storage_alive
    auxes = [] of HTS::Bam::Aux
    HTS::Bam.open(path_bam_string) do |bam|
      auxes = bam.map(&.aux)
    end

    GC.collect
    auxes[0].get_int("NM").should eq(1_i64)
    auxes[1].get_int("NM").should be_nil
  end

  def test_collection_helpers_at_eof
    HTS::Bam.open(path_bam_string) do |bam|
      bam.to_a.size.should eq(10)
      bam.first?.should be_nil
      bam.first(2).should be_empty
      bam.map(&.pos).should be_empty
      expect_raises(Enumerable::EmptyError) { bam.first }
    end
  end

  def test_stream_predicates_and_sum
    HTS::Bam.open(path_bam_string) do |bam|
      bam.count { |record| record.pos == 178 }.should eq(2)

      bam.rewind
      seen = [] of Int64
      bam.any? do |record|
        seen << record.pos
        record.pos == 474
      end.should be_true
      seen.should eq([178, 178, 474])
      bam.first.pos.should eq(809)

      bam.rewind
      bam.all? { |record| record.pos >= 0 }.should be_true
      bam.rewind
      bam.all? { |record| record.pos < 474 }.should be_false
      bam.first.pos.should eq(809)
      bam.rewind
      bam.none? { |record| record.pos < 0 }.should be_true
      bam.rewind
      bam.none? { |record| record.pos == 178 }.should be_false
      bam.first.pos.should eq(178)

      bam.rewind
      positions = bam.map(&.pos)
      bam.rewind
      bam.sum(&.pos).should eq(positions.sum)
      bam.rewind
      bam.sum(10_i64, &.pos).should eq(positions.sum + 10)
      bam.rewind
      bam.sum(10_i32, &.pos).should eq(positions.sum + 10)

      bam.sum(&.pos).should eq(0_i64)
      bam.sum(10_i64, &.pos).should eq(10_i64)
      bam.all? { |_| false }.should be_true
      bam.any? { |_| true }.should be_false
      bam.none? { |_| true }.should be_true
    end
  end

  def test_one_and_index_scan_reused_records
    HTS::Bam.open(path_bam_string) do |bam|
      bam.one? { |record| record.pos == 474 }.should be_true
      bam.rewind
      bam.one? { |record| record.pos == 178 }.should be_false
      bam.first.pos.should eq(474)
      bam.rewind
      bam.one? { |record| record.pos < 0 }.should be_false
      bam.one? { |_| true }.should be_false

      bam.rewind
      bam.index! { |record| record.pos == 178 }.should eq(0)
      bam.first.pos.should eq(178)
      bam.rewind
      bam.index { |record| record.pos == 474 }.should eq(2)
      bam.first.pos.should eq(809)
      bam.index { |_| false }.should be_nil
      expect_raises(Enumerable::NotFoundError) { bam.index! { |_| false } }
    end
  end

  def test_each_with_index_reuses_records
    HTS::Bam.open(path_bam_string) do |bam|
      positions = [] of {Int32, Int64}
      bam.each_with_index(5) do |record, index|
        positions << {index, record.pos}
      end.should be(bam)
      positions.first(3).should eq([{5, 178_i64}, {6, 178_i64}, {7, 474_i64}])
      positions.last[0].should eq(14)
    end
  end

  def test_each_copy_with_index_keeps_records_independent
    HTS::Bam.open(path_bam_string) do |bam|
      indexed = [] of {Int32, HTS::Bam::Record}
      bam.each_copy_with_index(5) do |record, index|
        indexed << {index, record}
      end.should be(bam)

      indexed.size.should eq(10)
      indexed.map(&.[0]).should eq((5...15).to_a)
      indexed[0][1].pos.should eq(178)
      indexed[2][1].pos.should eq(474)
      indexed[0][1].should_not be(indexed[1][1])
    end
  end

  def test_find_returns_an_independent_record
    HTS::Bam.open(path_bam_string) do |bam|
      matched = nil.as(HTS::Bam::Record?)
      found = bam.find do |record|
        matched = record if record.pos == 474
        record.pos == 474
      end
      found.should be(matched)
      found.try(&.pos).should eq(474)
      bam.first.pos.should eq(809)
      found.try(&.pos).should eq(474)

      bam.rewind
      bam.find! { |record| record.pos == 474 }.pos.should eq(474)
      bam.find(:missing) { |_| false }.should eq(:missing)
      bam.find { |_| false }.should be_nil
      bam.rewind
      expect_raises(Enumerable::NotFoundError) { bam.find! { |_| false } }
    end
  end

  def test_map_with_index_keeps_returned_records_independent
    HTS::Bam.open(path_bam_string) do |bam|
      indexed = bam.map_with_index(5) { |record, index| {index, record} }
      indexed.size.should eq(10)
      indexed.map(&.[0]).should eq((5...15).to_a)
      indexed[0][1].pos.should eq(178)
      indexed[2][1].pos.should eq(474)
      indexed[0][1].should_not be(indexed[1][1])
    end
  end

  def test_select_copies_only_matching_records
    HTS::Bam.open(path_bam_string) do |bam|
      expected = bam.to_a.select { |record| record.pos >= 474 }.map(&.qname)
      bam.rewind
      selected = bam.select { |record| record.pos >= 474 }
      selected.map(&.qname).should eq(expected)
      selected[0].should_not be(selected[1])

      bam.rewind
      bam.to_a.size.should eq(10)
      selected.map(&.qname).should eq(expected)
      bam.select { |_| true }.should be_empty
    end
  end

  def test_reject_returns_independent_records
    HTS::Bam.open(path_bam_string) do |bam|
      expected = bam.to_a.reject { |record| record.pos == 178 }.map(&.pos)
      bam.rewind
      rejected = bam.reject { |record| record.pos == 178 }
      rejected.map(&.pos).should eq(expected)
      rejected[0].should_not be(rejected[1])

      bam.rewind
      bam.to_a.size.should eq(10)
      rejected.map(&.pos).should eq(expected)
      bam.reject { |_| false }.should be_empty
    end
  end

  def test_partition_returns_two_independent_record_groups
    HTS::Bam.open(path_bam_string) do |bam|
      expected_matching, expected_other = bam.to_a.partition { |record| record.pos < 474 }
      bam.rewind
      matching, other = bam.partition { |record| record.pos < 474 }
      matching.map(&.qname).should eq(expected_matching.map(&.qname))
      other.map(&.qname).should eq(expected_other.map(&.qname))
      matching[0].should_not be(matching[1])
      other[0].should_not be(other[1])

      bam.rewind
      bam.to_a.size.should eq(10)
      matching.map(&.pos).should eq(expected_matching.map(&.pos))
      other.map(&.pos).should eq(expected_other.map(&.pos))
      bam.partition { |_| true }.should eq({[] of HTS::Bam::Record, [] of HTS::Bam::Record})
    end
  end

  def test_max_by_keeps_the_selected_record_and_borrowed_key_alive
    HTS::Bam.open(path_bam_string) do |bam|
      expected = bam.to_a.max_by(&.packed_sequence_view).qname
      bam.rewind
      selected = bam.max_by(&.packed_sequence_view)
      selected.qname.should eq(expected)

      bam.rewind
      first_qname = bam.first.qname
      bam.rewind
      bam.max_by?(&.mapq).try(&.qname).should eq(first_qname)
      selected.qname.should eq(expected)
      bam.max_by?(&.mapq).should be_nil
      expect_raises(Enumerable::EmptyError) { bam.max_by(&.mapq) }
    end
  end

  def test_min_by_keeps_the_selected_record_and_borrowed_key_alive
    HTS::Bam.open(path_bam_string) do |bam|
      expected = bam.to_a.min_by(&.packed_sequence_view).qname
      bam.rewind
      selected = bam.min_by(&.packed_sequence_view)
      selected.qname.should eq(expected)

      bam.rewind
      first_flag = bam.first.flag_value
      bam.rewind
      bam.min_by?(&.pos).try(&.flag_value).should eq(first_flag)
      selected.qname.should eq(expected)
      bam.min_by?(&.pos).should be_nil
      expect_raises(Enumerable::EmptyError) { bam.min_by(&.pos) }
    end
  end

  def test_minmax_by_keeps_both_selected_records_and_borrowed_keys_alive
    HTS::Bam.open(path_bam_string) do |bam|
      expected_min, expected_max = bam.to_a.minmax_by(&.packed_sequence_view)
      bam.rewind
      minimum, maximum = bam.minmax_by(&.packed_sequence_view)
      minimum.qname.should eq(expected_min.qname)
      maximum.qname.should eq(expected_max.qname)

      bam.rewind
      expected_tied_min, expected_tied_max = bam.to_a.minmax_by(&.mapq)
      bam.rewind
      tied_min, tied_max = bam.minmax_by?(&.mapq)
      tied_min.try(&.qname).should eq(expected_tied_min.qname)
      tied_max.try(&.qname).should eq(expected_tied_max.qname)
      minimum.qname.should eq(expected_min.qname)
      maximum.qname.should eq(expected_max.qname)
      bam.minmax_by?(&.pos).should eq({nil, nil})
      expect_raises(Enumerable::EmptyError) { bam.minmax_by(&.pos) }
    end
  end

  def test_native_position_and_thread_methods_raise_after_close
    bam = HTS::Bam.new(path_bam_string)
    bam.close

    expect_raises(IO::Error, "Closed stream") { bam.set_threads(1) }
    expect_raises(IO::Error, "Closed stream") { bam.threads = 1 }
    expect_raises(IO::Error, "Closed stream") { bam.seek(0) }
    expect_raises(IO::Error, "Closed stream") { bam.tell }
    expect_raises(IO::Error, "Closed stream") { bam.rewind }
  end

  def test_seek_raises_when_native_seek_fails
    [bam_string, sam_string, cram_string].each do |file|
      position = file.tell

      error = expect_raises(HTS::SeekError) { file.seek(-1_i64) }
      error.message.to_s.should contain(file.file_name)
      file.tell.should eq(position)
    end
  end

  def test_seek_rejects_offsets_outside_int64_before_calling_native_code
    [bam_string, sam_string, cram_string].each do |file|
      position = file.tell

      [UInt64::MAX, Int128::MIN].each do |offset|
        error = expect_raises(ArgumentError) { file.seek(offset) }
        error.message.to_s.should contain("outside the supported Int64 range")
        file.tell.should eq(position)
      end
    end
  end

  def test_seek_preserves_native_success_results
    sam_position = sam_string.tell || raise "SAM position unavailable"
    sam_string.seek(sam_position).should eq(sam_position)

    bam_position = bam_string.tell || raise "BAM position unavailable"
    bam_string.seek(bam_position).should eq(0)

    cram_string.seek(0).should eq(0)
  end

  def test_initialize_build_index_loads_index_lazily
    with_temp_indexable_bam do |path|
      bam = HTS::Bam.new(path, build_index: true)
      begin
        bam.index_loaded?.should be_false
        positions = [] of Int64
        bam.query("chr2:350-700") do |aln|
          positions << aln.pos
        end
        positions.should eq([341, 658])
        bam.index_loaded?.should be_true
      ensure
        bam.close
      end
    end
  end

  def test_load_index_retains_reloads_and_clears_the_index
    with_temp_indexable_bam do |path|
      HTS::Bam.build_index(path, verbose: false)
      bam = HTS::Bam.new(path)
      begin
        bam.load_index.should be(bam)
        bam.index_loaded?.should be_true
        bam.load_index.should be(bam)
        bam.index_loaded?.should be_true

        with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
          bam.try_load_index("#{path}.missing").should be_false
          expect_raises(HTS::Bam::MissingIndexError) { bam.load_index("#{path}.missing") }
        end
        bam.index_loaded?.should be_false
      ensure
        bam.close
      end
      bam.closed?.should be_true
    end
  end

  def test_file_level_aux_int
    values : Array(Int64?) = bam_string.aux_int("NM")
    expected = [] of Int64?
    bam_string.each do |aln|
      expected << aln.aux.get_int("NM")
    end
    (values).should eq(expected)
  end

  def test_file_level_aux_string
    values : Array(String?) = bam_string.aux_string("MC")
    expected = [] of String?
    bam_string.each do |aln|
      expected << aln.aux.get_string("MC")
    end
    (values).should eq(expected)
  end

  def test_each_aux_int
    values = [] of Int64?
    bam_string.each_aux_int("NM") do |value|
      values << value
    end
    (values).should eq(bam_string.aux_int("NM"))
  end

  def test_query_requires_index_for_sam
    ex = expect_raises(HTS::Bam::MissingIndexError) do
      sam_string.query("chr1:1-10") { |_| }
    end
    (ex.message.to_s).should contain(path_sam_string)
    (ex.message.to_s).should contain("Query requires an index")
  end

  def test_query_invalid_region_message_bam
    ex = expect_raises(HTS::Bam::QueryError) do
      bam_string.query("chrX:1-10") { |_| }
    end
    (ex.message.to_s).should contain("chrX:1-10")
    (ex.message.to_s).should contain(path_bam_string)
  end

  def test_query_invalid_tid_message_bam
    ex = expect_raises(ArgumentError) do
      bam_string.query(-1, 0_i64, 10_i64) { |_| }
    end
    (ex.message.to_s).should contain("tid (-1)")
  end

  def test_query_invalid_chrom_message_bam
    ex = expect_raises(ArgumentError) do
      bam_string.query("chrX", 1_i64, 10_i64) { |_| }
    end
    (ex.message.to_s).should contain(path_bam_string)
    (ex.message.to_s).should contain("Unknown reference name")
  end
end

describe BamTest do
  {% for method in BamTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamTest.new
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
