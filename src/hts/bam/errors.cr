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

    class HeaderError < Error
    end

    class RecordError < Error
    end

    class ReadError < Error
    end

    class WriteError < Error
    end

    class FastaIndexError < Error
    end

    class PileupError < Error
    end

    class MpileupError < Error
    end

    class AuxError < Error
    end

    class AuxTypeError < AuxError
    end

    class AuxUpdateError < AuxError
    end
  end
end
