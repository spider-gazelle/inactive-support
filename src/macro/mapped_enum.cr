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
macro mapped_enum(name, *members, &block)
  {% begin %}
    {% if name.is_a? Generic %}
      {% type_name = name.name.id %}
      {% mapped_type = name.type_vars[0].id %}
      {% strict = true %}
    {% else %}
      {% type_name = name.id %}
      {% strict = false %}
    {% end %}
    enum {{type_name}}
      {% for member in members %}
        {{member.target.id}}
      {% end %}

      # Returns the enum member that has the given mapped value, or yields if no
      # such member exists.
      {% if strict %}
        def self.from_mapped_value(value : {{mapped_type}}, & : {{mapped_type}} -> T) : self | T forall T
      {% else %}
        def self.from_mapped_value(value, &)
      {% end %}
        case value
        {% for member in members %}
          when {{member.value}} then {{type_name}}::{{member.target.id}}
        {% end %}
        else
          yield value
        end
      end

      # Returns the enum member that has the given mapped value, or raises if no
      # such member exists.
      {% if strict %}
        def self.from_mapped_value(value : {{mapped_type}}) : self
      {% else %}
        def self.from_mapped_value(value) : self
      {% end %}
        from_mapped_value(value) { raise "Unmapped value for enum #{self}: #{value}" }
      end

      # :ditto:
      {% if strict %}
        def self.[](value : {{mapped_type}}) : self
      {% else %}
        def self.[](value) : self
      {% end %}
        from_mapped_value value
      end

      # Returns the enum member that has the given mapped value, or `nil` if no
      # such member exists.
      {% if strict %}
        def self.from_mapped_value?(value : {{mapped_type}}) : self?
      {% else %}
        def self.from_mapped_value?(value) : self?
      {% end %}
        from_mapped_value(value) { nil }
      end

      # :ditto:
      {% if strict %}
        def self.[]?(value : {{mapped_type}}) : self?
      {% else %}
        def self.[]?(value) : self?
      {% end %}
        from_mapped_value? value
      end

      # Returns the `Tuple` of all mapped values.
      def self.mapped_values
        {{members.map &.value}}
      end

      # Returns the value mapped to `self`.
      {% if strict %}
        def mapped_value : {{mapped_type}}
      {% else %}
        def mapped_value
      {% end %}
        case self
        {% for member in members %}
          in {{type_name}}::{{member.target.id}} then {{member.value}}
        {% end %}
        end
      end

      {% if block %}
        {{block.body}}
      {% end %}
    end
  {% end %}
end
