module HTS
  module Utils
    def warn(*messages)
      STDERR.puts(*messages) unless messages.empty?
    end
  end
end