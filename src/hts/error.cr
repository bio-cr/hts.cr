module HTS
  class Error < Exception
  end

  class ThreadError < Error
  end

  class FileFormatError < Error
  end

  class RewindError < Error
  end

  class CloseError < Error
  end
end
