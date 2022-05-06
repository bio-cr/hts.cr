module HTS
  module LibHTS2 # FIXME
    extend self
    # constants

    def bgzf_tell(fp)
      (fp.value.block_address << 16) | (fp.value.block_offset & 0xFFFF)
    end
  end
end
