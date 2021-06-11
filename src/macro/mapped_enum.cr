# Defines a enum where each member holds a reference to an associated value.
#
# This may be used to define enum over non-integer types, whilst keeping the
# same type safety that integer-backed enums provide.
#
# ```
# mapped_enum Example(String),
#   A = "foo",
#   B = "bar",
#   C = "baz"
# ```
#
# Instances may be read from mapped values
# ```
# Example.from_mapped_value "foo" # => Example::A
# ```
#
# A short-form syntax is also available for this
# ```
# Example["foo"] # => Example::A
# ```
#
# Mapped values may also be extracted
# ```
# Example::A.mapped_value # => "foo"
# ```
#
# All other functionality, performance and safety that enums provide holds.

struct Enum::Mapping(T, U)
  def initialize(enum_type : T.class, @values : Indexable(U)); end

  # Returns the enum member that has the given mapped value, or yields if no such
  # member exists.
  def from_mapped_value(x : U, & : U -> V) : T | V forall V
    if value = values.index(x)
      T.from_value value
    else
      yield x
    end
  end

  # Returns the enum member that has the given mapped value, or raises if no such
  # member exists.
  def [](x : U) : T
    from_mapped_value(x) { raise "No mapping exists from #{x} to #{T}" }
  end

  # Returns the enum member that has the given mapped value, or `nil` if no such
  # member exists.
  def []?(x : U) : T?
    from_mapped_value(x) { nil }
  end

  # Returns the list of all mapped values.
  def values : Indexable(U)
    @values
  end

  # Returns the mapped value for the enum member at the given value.
  def mapped_value(i : Int) : U
    values[i]
  end
end

macro mapped_enum(name, &block)
  {% begin %}
    {% enum_type = name.id %}
    {% body_type = "#{enum_type}__body".id %}
    {% mapping = "#{enum_type}__mapping".id %}

    module {{body_type}}
      {{block.body}}
    end

    enum {{enum_type}}
      \{% for member in {{body_type}}.constants %}
        \{{member}}
      \{% end %}

      def self.[](mapped_value) : self
        {{mapping}}[mapped_value]
      end

      def self.[]?(mapped_value) : self?
        {{mapping}}[mapped_value]?
      end

      def self.mapped_values
        {{mapping}}.values
      end

      def mapped_value
        {{mapping}}.mapped_value self.value
      end
    end

    private {{mapping}} = Enum::Mapping.new {{enum_type}}, \{{ {{body_type}}.constants.map { |t| "{{body_type}}::#{t}".id } }}
  {% end %}
end
