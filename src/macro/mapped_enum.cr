# Annotation for attaching arbitrary value mappings to Enum types.
#
# When applied, a positional arg must exist for each enum meber
# ```
# @[MappedValues("foo", "bar", 42)]
# enum Foo
#   A
#   B
#   C
# end
# ```
annotation MappedValues
end

struct Enum
  # Provides the Tuple of values associated with members of `self`.
  def self.mapped_values
    {% if ann = @type.annotation(MappedValues) %}
      {% values = ann.args %}
      {% if values.size == @type.constants.size %}
        {{ values }}
      {% else %}
        {{ raise "MappedValues does not match the number of members in #{@type}" }}
      {% end %}
    {% else %}
      {{ raise "No MappedValues defined for #{@type}" }}
    {% end %}
  end

  # Returns the enum member that has the given mapped value, or yields if no
  # such member exists.
  def self.from_mapped_value(mapped_value : T, & : T -> U) : self | U forall T, U
    if value = mapped_values.index(mapped_value)
      self.from_value value
    else
      yield mapped_value
    end
  end

  # Returns the enum member that has the given mapped value, or raises if no
  # such member exists.
  def self.from_mapped_value(mapped_value) : self
    from_mapped_value(mapped_value) do
      raise "No mapping exists from #{mapped_value} to #{self}"
    end
  end

  # Returns the enum member that has the given mapped value, or `nil` if no such
  # member exists.
  def self.from_mapped_value?(mapped_value) : self?
    from_mapped_value(mapped_value) { nil }
  end

  # Returns the mapped value for the enum member.
  def mapped_value
    self.class.mapped_values[self.value]
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
# Members may statically accessed from mapped values
# ```
# Example["foo"] # => Example::A
# ```
#
# Or resolved dynamically
# ```
# value = "foo"
# Example.from_mapped_value value # => Example::A
# ```
#
# Mapped values may also be extracted
# ```
# Example::A.mapped_value # => "foo"
# ```
#
# All other functionality, performance and safety that enums provide holds.
macro mapped_enum(name, &block)
  {% enum_type = name.id %}
  {% body_type = "#{enum_type}__".id %}

  # Throwaway type for expanding the block into for parsing.
  private module {{body_type}}
    {{block.body}}
  end

  \{% begin %}
    @[MappedValues(\{{ {{body_type}}.constants.map { |x| {{body_type}}.constant(x) }.splat }})]
    enum {{enum_type}}
      \{% for member in {{body_type}}.constants %}
        \{{member}}
      \{% end %}

      \{% verbatim do %}
        # Provides compile-time resolution from a statically known mapped value
        # to a member of `self`.
        macro [](mapped_value)
          \{% if mapped_value.is_a? Path %}
            \{% value = mapped_value.resolve %}
          \{% elsif mapped_value.is_a? Var %}
            \{{ raise "Cannot statically resolve #{mapped_value} - use #{@type}.from_mapped_value to lookup at runtime" }}
          \{% else %}
            \{% value = mapped_value %}
          \{% end %}

          \{% found = false %}
          \{% for member_value, idx in @type.annotation(MappedValues).args %}
            \{% if value == member_value && !found %}
              \{% found = true %}
              \{{ "#{@type.name}::#{@type.constants[idx]}".id }}
            \{% end %}
          \{% end %}

          \{{ raise "No mapping defined from #{value} to #{@type}" unless found }}
        end
      \{% end %}

      \{% for method in {{body_type}}.class.methods %}
        \{{method.id}}
      \{% end %}

      \{% for method in {{body_type}}.methods %}
        \{{method.id}}
      \{% end %}
    end
  \{% end %}
end
