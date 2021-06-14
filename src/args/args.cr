# Creates a NamedTuple containing the arguments of the surround method.
#
# This can be used as an alternative to a double splat arg to enforce a strict
# type, but provide a simple accessor for methods acting as a thin proxy.
macro args
  {% verbatim do %}
    {% raise "args macro can only be used within a method" if @def.is_a? NilLiteral %}
    {% begin %}
    {
      {% args = @def.args %}
      {% args << @def.double_splat if @def.double_splat %}
      {% for arg in args %}
        {{arg.internal_name.id}}: {{arg.internal_name}},
      {% end %}
    }
    {% end %}
  {% end %}
end
