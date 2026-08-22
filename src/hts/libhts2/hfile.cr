module HTS
  module LibHTS2
    extend self

    HFILE_AT_EOF   = 1_u32 << 0
    HFILE_MOBILE   = 1_u32 << 1
    HFILE_READONLY = 1_u32 << 2
    HFILE_PRESERVE = 1_u32 << 3

    def hfile_at_eof?(fp : LibHTS::HFile*) : Bool
      !fp.null? && (fp.value.bitfields & HFILE_AT_EOF) != 0
    end

    def hfile_mobile?(fp : LibHTS::HFile*) : Bool
      !fp.null? && (fp.value.bitfields & HFILE_MOBILE) != 0
    end

    def hfile_readonly?(fp : LibHTS::HFile*) : Bool
      !fp.null? && (fp.value.bitfields & HFILE_READONLY) != 0
    end

    def hfile_preserve?(fp : LibHTS::HFile*) : Bool
      !fp.null? && (fp.value.bitfields & HFILE_PRESERVE) != 0
    end

    def htell(fp)
      fp.value.offset + (fp.value._begin - fp.value.buffer)
    end
  end
end
