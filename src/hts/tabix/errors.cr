module HTS
  class Tabix < Bgzf
    class Error < HTS::Error; end

    class OpenError < Error; end

    class IndexError < Error; end

    class MissingIndexError < IndexError; end

    class QueryError < Error; end

    class ReadError < Error; end
  end
end
