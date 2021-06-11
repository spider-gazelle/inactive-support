# Inactive Support

A collection of classes, modules, macros and standard library extensions to simplify common tasks in crystal-lang.

Each tool is small, independent and generic.
To use a tool, explicitly `require` where needed.
Their usage should be highly intentional and not a default choice.


## Tools

### `collection`

The `Collection` module provides an interface and tools for working with any collection type.
This includes both index and key-based containers.

When required it will extend all compatible types with the std lib.
To use with domain types
```
include Collection(KeyOrIndexType, ValueType)
```

It provides standardised access to elements and the ability to lazily traverse nested structures.

```crystal
nested = {
  a: 42,
  b: [:foo, :bar, :baz],
  c: {"hello" => "world"},
}

nested.traverse.to_h # =>
# {
#   {:a}          => 42,
#   {:b, 0}       => :foo,
#   {:b, 1}       => :bar,
#   {:b, 2}       => :baz,
#   {:c, "hello"} => "world",
# }
```


### `core_ext/presence`

Provides `Object#presence`.

This Allows one to check for the presence of useful data in container types such as `Array` and `Hash`.

```crystal
# hash loaded from config file or database
# imagine this is `Hash(String, String) | Nil`
my_hash = {} of String => String

# set some defaults
my_hash = my_hash.presence || {"default" => "settings"}
```


### `macro/args`

Enables `args` to be stated anywhere within a method body.
This is substituted with a NamedTuple containing the arguments of the surrounding method.

```crystal
def example(a : String, b : String, c : String)
  args
end

example "foo", "bar", "baz" # => {a: "foo", b: "bar", c: "baz"}
```


### `macro/mapped_enum`

Provides a lightweight syntax for defining non-integer enum types.
```crystal
mapped_enum Example(String),
  A = "foo",
  B = "bar",
  C = "baz"
```
The type may be optionally ommitted, but is recommended for increased compile-time safety.

Instances may be read from mapped values
```crystal
Example.from_mapped_value "foo" # => Example::A
```
or
```crystal
Example["foo"] # => Example::A
```

Mapped values may also be extracted
```crystal
Example::A.mapped_value # => "foo"
```

All other functionality and safety that enums provide holds.
