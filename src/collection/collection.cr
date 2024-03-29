require "./diggable"

# The `Collection` module provides an interface and tools for working with any
# collection type. This includes both index and key-based containers.
#
# More formally, it models any type that provides a binary relation from X to Y.
module Collection(X, Y)
  # Returns the value for the given *key_or_index*, or `nil`.
  def []?(key_or_index : X) : Y?
    # FIXME: switch this to an abstract method when possible.
    # See https://github.com/crystal-lang/crystal/issues/8232
    {{ raise "`##{@def.name}` must be implemented by #{@type}" }}
  end

  # Returns the value for the given *key_or_index*.
  def [](key_or_index : X) : Y
    # This is likely overridden by any including types, but as a fallback we can
    # safely derive a naive implementation for non-nilable types
    {% if Y.nilable? %}
      {{ raise "`##{@def.name}` must be implemented by #{@type}" }}
    {% else %}
      self[key_or_index]? || begin
        if key_of_index.is_a? Int
          raise IndexError.new
        else
          raise KeyError.new("Missing #{@type} key \"#{key_or_index}\"")
        end
      end
    {% end %}
  end

  # Traverses the depth of a structure and returns the value.
  abstract def dig(key : X, *subkeys)

  # Traverses the depth of a structure and returns the value, or nil.
  abstract def dig?(key : X, *subkeys)

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

  # True is `self` is a nested structure.
  def nested? : Bool
    {% if Y <= @type %}
      # This must be overridden by recursive types to flag when recusion has
      # reached the bottom of the available data.
      {{ raise "`##{@def.name}` must be implemented by #{@type}" }}
    {% elsif Y <= Collection || Y.union? && Y.union_types.any? &.<= Collection %}
      true
    {% else %}
      false
    {% end %}
  end

  macro included
    include Digable(X)

    # Recursive types (such as `JSON::Any`) require some special handling.
    # Unfortunately this involves bluring the path types from a Tuple down to an
    # Array to avoid infinite expansion. Under most usage scenarios this should
    # be relatively transparent to external users though.
    {% if Y <= @type && Y != NoReturn %}

      # Traverse the structure depth first yielding a tuple of the path through
      # the structure and the leaf value for every element to the passed block.
      #
      # The paths contain an Array of the keys or indicies used across
      # intermediate structures, similar to what would be passed to `#dig`.
      def traverse(&block : {Array(X), Y} ->) : Nil forall T
        traverse [] of X, &block
      end

      # :ditto:
      def traverse(*prefix : *T, &block : {Array(Union(*T, X)), Y} ->) : Nil forall T
        traverse prefix.to_a, &block
      end

      # :nodoc:
      protected def traverse(prefix : Array(T), &block : {Array(T | X), Y} ->) : Nil forall T
        each_pair do |(key, value)|
          path = prefix.map &.as(T | X) << key

          if value.nested?
            value.traverse(path, &block)
          else
            yield({ path, value })
          end
        end
      end

      # Provides an Iterator that will traverse the structure.
      def traverse : Iterator({Array(X), Y})
        traverse [] of X
      end

      # :ditto:
      def traverse(*prefix : *T) : Iterator({Array(Union(*T, X)), Y}) forall T
        traverse prefix.to_a
      end

      # :nodoc:
      protected def traverse(prefix : Array(T)) : Iterator({Array(T | X), Y}) forall T
        # FIXME: the is supremely inefficient, a nasty lie, and a dirty hack...
        # but works within the realms of the current type system / compiler.
        # This should be rewritten to provide lazy parsing of the underlying
        # structure when possible.
        entries = [] of {Array(T | X), Y}
        traverse prefix do |entry|
          entries = entries << entry
        end
        entries.each
      end

    {% else %}

      # Traverse the structure depth first yielding a tuple of the path through
      # the structure and the leaf value for every element to the passed block.
      #
      # The paths contain a tuple of the keys or indicies used across
      # intermediate structures, similar to what would be passed to `#dig`.
      def traverse(*prefix : *T, &block) : Nil forall T
        each_pair do |(key, value)|
          path = Tuple.new(*prefix, key)

          if value.is_a? Collection
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

          if value.is_a? Collection
            value.traverse(*path)
          else
            {path, value}
          end
        end
      end

    {% end %}
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

require "./core_ext"
