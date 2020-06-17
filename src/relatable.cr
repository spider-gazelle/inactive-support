# The `Relatable` module provides an interface and tools for working with
# collections that map keys or indicies to values.
#
# More formally, it models any type that provides a binary relation from X to Y.
module Relatable(X, Y)
  # Must yield this structure's key, value or index, element pairs.
  abstract def each_pair(&block : {X, Y} ->) : Nil

  # Provides an `Iterator` for each pair in `self`.
  #
  # NOTE: when the base collection provides it own iterator implementation, this
  # method should be overridden to use this directly, this is a generalised
  # implementation and likely sub-optimal in many cases.
  def each_pair : Iterator({X, Y})
    ItemIterator({X, Y}).new self
  end

  # Traverse the structure depth first yielding a tuple of the path through the
  # structure and the leaf value for every element to the passed block.
  #
  # The paths contain a tuple of the keys or indicies used across intermediate
  # structures, similar to what would be passed to the `#dig` method.
  def traverse(*prefix : *T, &block) : Nil forall T
    each_pair do |(key, value)|
      path = Tuple.new(*prefix, key)
      if value.is_a? Relatable
        value.traverse(*path) { |pair| yield pair }
      else
        yield({path, value})
      end
    end
  end

  # Provide an iterator that may be used to traverse a nested structure.
  def traverse(*prefix : *T) : Iterator forall T
    each_pair.flat_map do |(key, value)|
      path = Tuple.new(*prefix, key)
      if value.is_a? Relatable
        value.traverse(*path)
      else
        {path, value}
      end
    end
  end

  private class ItemIterator(T)
    include Iterator(T)

    def initialize(structure)
      @channel = Channel(T).new
      spawn same_thread: true do
        structure.each_pair { |item| @channel.send item }
        @channel.close
      end
    end

    def next
      @channel.receive? || stop
    end
  end
end

module Indexable(T)
  include Relatable(Int32, T)

  def each_pair(&block) : Nil
    each_with_index { |e, i| yield({i, e}) }
  end

  def each_pair : Iterator({Int32, T})
    each.with_index.map { |(e, i)| {i, e} }
  end
end

struct NamedTuple(T)
  # FIXME: the co-domain should be a `Union(T.values)`, however this is not
  # expressable with the current compiler.
  # See: https://github.com/crystal-lang/crystal/issues/6757
  include Relatable(Symbol, NoReturn)

  def each_pair(&block) : Nil
    each { |k, v| yield({k, v}) }
  end

  def each_pair : Iterator
    to_a.each
  end
end

class Hash(K, V)
  include Relatable(K, V)

  def each_pair(&block) : Nil
    each { |k, v| yield({k, v}) }
  end

  def each_pair : Iterator({K, V})
    each
  end
end
