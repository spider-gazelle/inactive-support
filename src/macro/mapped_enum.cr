# Struct for associating an enum with a set of arbitrary values - one for each
# member.
struct Enum::Mapping(T, U)
  def initialize(enum_type : T.class, @values : Indexable(U)); end

  # Mapped values, where indicies are `T.value`.
  getter values

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

  # Returns the mapped value for the enum member.
  def mapped_value(x : T) : U
    values[x.value]
  end
end

# Defines a enum where each member holds a reference to an associated value.
#
# This may be used to define enum over non-integer types, whilst keeping the
# same type safety that integer-backed enums provide.
#
# ```
# mapped_enum Example do
#   A = "foo"
#   B = "bar"
#   C = "baz"
# end
# ```
#
# Instances may be read from mapped values
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
macro mapped_enum(name, &block)
  {% begin %}
    {% enum_type = name.id %}
    {% body_type = "#{enum_type}__body".id %}
    {% mapping = "#{enum_type}__mapping".id %}

    private module {{body_type}}
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
        {{mapping}}.mapped_value self
      end

      \{% for method in {{body_type}}.class.methods %}
        \{{method.id}}
      \{% end %}

      \{% for method in {{body_type}}.methods %}
        \{{method.id}}
      \{% end %}
    end

    private {{mapping}} = Enum::Mapping.new {{enum_type}}, \{{ {{body_type}}.constants.map { |t| "{{body_type}}::#{t}".id } }}
  {% end %}
end
