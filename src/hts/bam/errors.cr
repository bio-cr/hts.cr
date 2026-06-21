module HTS
  class Bam < Hts
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

    class AuxError < Error
    end

    class AuxTypeError < AuxError
    end
  end
end
