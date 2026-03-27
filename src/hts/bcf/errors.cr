module HTS
  class Bcf < Hts
    class Error < HTS::Error
    end

    class OpenError < Error
    end

    class IndexError < Error
    end

    class MissingIndexError < IndexError
    end

    class QueryError < Error
    end

    class HeaderError < Error
    end

    class SubsetError < HeaderError
    end

    class UnknownSampleError < SubsetError
    end
  end
end
