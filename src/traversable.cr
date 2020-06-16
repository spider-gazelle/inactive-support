require "json"
require "yaml"

# The `Traversable` module is a mixin that provides tools for working with
# nested structures of arbitrary depth.
#
# NOTE: `A` and `B` intentially chosen as type vars in place of the more
# reasonable `K` and `V` as a workaround for
# https://github.com/crystal-lang/crystal/issues/9488
module Traversable(A, B)
  # Must yield this structure's key, value or index, element pairs.
  abstract def each_pair(&block : {A, B} ->) : Nil

  macro included
    {% if B <= @type %}
      def traverse(*prefix : *T, &block : {Indexable(Union(*T, A)), B} ->) : Nil forall T
        traverse(prefix.to_a, &block)
      end

      def traverse(prefix : Array(T), &block : {Array(Union(T, A)), B} ->) : Nil forall T
        each_pair do |(key, value)|
          path = prefix.dup.as(Array(Union(T, A))) << key

          if value.as_h? || value.as_a?
            value.traverse(path, &block)
          else
            yield({ path, value })
          end
        end
      end
    {% else %}
      # Traverse the structure depth first yielding a tuple of the path through the
      # structure and the leaf value for every element to the passed block.
      #
      # The paths contain a tuple of the keys or indicies used across intermediate
      # structures, similar to what would be passed to the `#dig` method.
      def traverse(*prefix : *T, &block) : Nil forall T
        each_pair do |(key, value)|
          path = Tuple.new(*prefix, key)

          if value.is_a? Traversable
            value.traverse(*path) { |pair| yield pair }
          else
            yield({ path, value })
          end
        end
      end
    {% end %}
  end

  # Provides an Iterator that will traverse the structure.
  #
  # FIXME: the is supremely inefficient, a nasty lie, and a dirty hack... but
  # works within the realms of the current type system / compiler. This should
  # be rewritten to provide lazy parsing of the underlying structure when
  # possible.
  def traverse : Iterator
    entries = [] of {A, B}

    traverse do |entry|
      entry_arr = Array(typeof(entry)).new 1, entry
      entries = entries + entry_arr
    end

    entries.each
  end
end

module Enumerable(T)
  include Traversable(Int, T)

  def each_pair(&block) : Nil
    each_with_index { |e, i| yield({ i, e }) }
  end
end

struct NamedTuple(T)
  include Traversable(Symbol, Union(T))

  def each_pair(&block) : Nil
    each { |k, v| yield({ k, v }) }
  end
end

class Hash(K, V)
  include Traversable(K, V)

  def each_pair(&block) : Nil
    each { |k, v| yield({ k, v }) }
  end
end

struct JSON::Any
  include Traversable(String | Int32, JSON::Any)

  def each_pair(&block : {String | Int32, JSON::Any} ->) : Nil
    if value = as_h? || as_a?
      value.each_pair { |k, v| yield({ k, v }) }
    end
  end
end

struct YAML::Any
  # TODO
  # include Traversable(String | Int32, JSON::Any::Type)
end



nested = {
  :foo => {
    :bar => {
      :baz => 1234
    },
    :x => { :a, :b, :c },
  },
  :qux => "abc"
}

t = { foo: { bar: :baz } }
# => [:foo, :bar, :baz], 1234
# => [:qux], "abc"

puts t.traverse.to_a

nested.traverse { |e| puts e }

puts nested.traverse.to_a

puts "---"
JSON.parse(nested.to_json).each_pair { |e| puts typeof(e).to_s }
JSON.parse(nested.to_json).traverse([] of (Int32 | String)) { |p| puts p }

