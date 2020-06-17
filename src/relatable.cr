# The `Relatable` module provides an interface and tools for working with
# collections that map keys or indicies to values.
#
# More formally, it models any type that provides a binary relation from X to Y.
module Relatable(X, Y)
  # Must yield this structure's key, value or index, element pairs.
  abstract def each_pair(&block : {X, Y} ->) : Nil

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
        yield({ path, value })
      end
    end
  end
end

module Indexable(T)
  include Relatable(Int32, T)

  def each_pair(&block) : Nil
    each_with_index { |e, i| yield({ i, e }) }
  end
end

struct NamedTuple(T)
  include Relatable(Symbol, Union(T))

  def each_pair(&block) : Nil
    each { |k, v| yield({ k, v }) }
  end
end

class Hash(K, V)
  include Relatable(K, V)

  def each_pair(&block) : Nil
    each { |k, v| yield({ k, v }) }
  end
end
