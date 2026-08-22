module HTS
  module LibHTS2
    extend self

    def htell(fp)
      fp.value.offset + (fp.value._begin - fp.value.buffer)
    end
  end
end
