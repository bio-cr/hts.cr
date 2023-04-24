module HTS
  module LibHTS2
    extend self

    # constants

    def htell(fp)
      fp.value.offset + (fp.value._begin - fp.value.buffer)
    end
  end
end
