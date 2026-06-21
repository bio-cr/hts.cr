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

    class ReadError < Error
    end

    class WriteError < Error
    end

    class HeaderError < Error
    end

    class RecordError < Error
    end

    class SubsetError < HeaderError
    end

    class UnknownSampleError < SubsetError
    end

    class FieldError < Error
    end

    class InfoError < FieldError
    end

    class InfoDefinitionError < InfoError
    end

    class InfoTypeError < InfoError
    end

    class InfoReadError < InfoError
    end

    class InfoUpdateError < InfoError
    end

    class UnsupportedInfoOperationError < InfoError
    end

    class FormatError < FieldError
    end

    class FormatDefinitionError < FormatError
    end

    class FormatTypeError < FormatError
    end

    class FormatReadError < FormatError
    end

    class FormatUpdateError < FormatError
    end

    class UnsupportedFormatOperationError < FormatError
    end
  end
end
