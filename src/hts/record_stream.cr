module HTS
  # Collection helpers for readers whose `each` reuses a record.
  # Implementing readers must provide `each_copy` for retained results, and
  # records must support `clone`. A record returned by an early exit from
  # `each` must continue owning its native storage.
  # Each traversal consumes records from the reader's current position.
  module RecordStream(T)
    def count(& : T ->) : Int32
      result = 0
      each { |record| result += 1 if yield record }
      result
    end

    def any?(& : T ->) : Bool
      each { |record| return true if yield record }
      false
    end

    def all?(& : T ->) : Bool
      each { |record| return false unless yield record }
      true
    end

    def none?(& : T ->) : Bool
      each { |record| return false if yield record }
      true
    end

    def one?(& : T ->) : Bool
      found = false
      each do |record|
        if yield record
          return false if found
          found = true
        end
      end
      found
    end

    # Yields the same reused record as `each`.
    def each_with_index(offset = 0, &) : self
      index = offset
      each do |record|
        yield record, index
        index += 1
      end
      self
    end

    # Yields an independent record for every index.
    def each_copy_with_index(offset = 0, &) : self
      index = offset
      each_copy do |record|
        yield record, index
        index += 1
      end
      self
    end

    # Stops before the matching record can be reused by the next read.
    def find(if_none = nil, & : T ->)
      each do |record|
        return record if yield record
      end
      if_none
    end

    def find!(& : T ->) : T
      find { |record| yield record } || raise Enumerable::NotFoundError.new
    end

    def first(& : ->)
      each { |record| return record }
      yield
    end

    def first : T
      first { raise Enumerable::EmptyError.new }
    end

    def first? : T?
      first { nil }
    end

    def first(count : Int) : Array(T)
      raise ArgumentError.new("Attempt to take negative size") if count < 0

      ary = [] of T
      return ary if count == 0

      each_copy do |record|
        ary << record
        break if ary.size == count
      end
      ary
    end

    # Returns an ordinal from the reader's current position.
    def index(& : T ->) : Int32?
      each_with_index do |record, ordinal|
        return ordinal if yield record
      end
      nil
    end

    def index!(& : T ->) : Int32
      index { |record| yield record } || raise Enumerable::NotFoundError.new
    end

    def to_a : Array(T)
      ary = [] of T
      each_copy { |record| ary << record }
      ary
    end

    # The block receives a copy; its result must own any data it retains.
    def map(& : T -> U) : Array(U) forall U
      ary = [] of U
      each_copy { |record| ary << yield record }
      ary
    end

    # The block receives a copy; its result must own any data it retains.
    def map_with_index(offset = 0, & : T, Int32 -> U) : Array(U) forall U
      ary = [] of U
      each_copy_with_index(offset) { |record, index| ary << yield record, index }
      ary
    end

    # Only matching records need an independent copy.
    def select(& : T ->) : Array(T)
      ary = [] of T
      each { |record| ary << record.clone if yield record }
      ary
    end

    # Only matching records need an independent copy.
    def reject(& : T ->) : Array(T)
      ary = [] of T
      each { |record| ary << record.clone unless yield record }
      ary
    end

    # Both results retain records, so each record is copied once.
    def partition(& : T ->) : {Array(T), Array(T)}
      matching = [] of T
      other = [] of T
      each do |record|
        if yield record
          matching << record.clone
        else
          other << record.clone
        end
      end
      {matching, other}
    end

    # Restrict the accumulator to numeric values so this can use `each`.
    def sum(& : T -> U) : U forall U
      {% unless U <= Number %}
        {% raise "RecordStream#sum requires a numeric block result" %}
      {% end %}

      initial = if U.responds_to? :additive_identity
                  U.additive_identity
                else
                  U.zero
                end
      sum(initial) { |record| yield record }
    end

    def sum(initial : U, & : T -> V) forall U, V
      {% unless U <= Number && V <= Number %}
        {% raise "RecordStream#sum requires numeric initial and block result values" %}
      {% end %}

      result = initial
      each { |record| result += yield record }
      result
    end

    def max_by(& : T -> U) : T forall U
      max_by? { |record| yield record } || raise Enumerable::EmptyError.new
    end

    # Keep the winning record alive in case its comparison key borrows from it.
    def max_by?(& : T -> U) : T? forall U
      extreme_by?(false) { |record| yield record }
    end

    def min_by(& : T -> U) : T forall U
      min_by? { |record| yield record } || raise Enumerable::EmptyError.new
    end

    # Keep the winning record alive in case its comparison key borrows from it.
    def min_by?(& : T -> U) : T? forall U
      extreme_by?(true) { |record| yield record }
    end

    def minmax_by(& : T -> U) : {T, T} forall U
      minimum, maximum = minmax_by? { |record| yield record }
      if minimum && maximum
        {minimum, maximum}
      else
        raise Enumerable::EmptyError.new
      end
    end

    # Keep both selected records alive when their comparison keys borrow from them.
    def minmax_by?(& : T -> U) : {T, T} | {Nil, Nil} forall U
      minimum = nil.as(T?)
      maximum = nil.as(T?)
      minimum_key = uninitialized U
      maximum_key = uninitialized U

      each_copy do |record|
        key = yield record
        if minimum.nil?
          minimum = maximum = record
          minimum_key = maximum_key = key
        else
          min_comparison = key <=> minimum_key
          raise ArgumentError.new("Comparison of #{key} and #{minimum_key} failed") if min_comparison.nil?
          if min_comparison < 0
            minimum = record
            minimum_key = key
          end

          max_comparison = key <=> maximum_key
          raise ArgumentError.new("Comparison of #{key} and #{maximum_key} failed") if max_comparison.nil?
          if max_comparison > 0
            maximum = record
            maximum_key = key
          end
        end
      end

      if minimum && maximum
        {minimum, maximum}
      else
        {nil, nil}
      end
    end

    private def extreme_by?(minimum : Bool, & : T -> U) : T? forall U
      best = nil.as(T?)
      best_key = uninitialized U

      each_copy do |record|
        key = yield record
        if best.nil?
          best = record
          best_key = key
        else
          comparison = key <=> best_key
          raise ArgumentError.new("Comparison of #{key} and #{best_key} failed") if comparison.nil?
          better = minimum ? comparison < 0 : comparison > 0
          if better
            best = record
            best_key = key
          end
        end
      end
      best
    end

    # Only use this for accessors that return values owned by the caller.
    private def collect_record_values(& : T -> U) : Array(U) forall U
      ary = [] of U
      each { |record| ary << yield record }
      ary
    end
  end
end
