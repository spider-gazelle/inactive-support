# Inactive Support

A collection of classes, modules, macros and standard library extensions to simplify common tasks in crystal-lang.

Each tool is small, independent and generic.
To use a tool, explicitly `require` where needed.

```crystal
require "inactive_support/<tool name>"
```

Their usage should be highly intentional and not a default choice.


## Tools

### `args`

Enables `args` to be stated anywhere within a method body.
This is substituted with a NamedTuple containing the arguments of the surrounding method.

```crystal
def example(a : String, b : String, c : String)
  args
end

example "foo", "bar", "baz" # => {a: "foo", b: "bar", c: "baz"}
```


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


### `mapped_enum`

Provides support for defining non-integer enum types.
```crystal
mapped_enum Example do
  A = "foo"
  B = "bar"
  C = "baz"
end
```

Members may be accessed via a compile-time lookup from their mapped value
```crystal
Example["foo"] # => Example::A
```

Attempting static resolution for an unmapped value will result in a compile error
```crystal
Example["qux"]

Error: No mapping defined from "qux" to Example
```

Instances may be read dynamically
```crystal
Example.from_mapped_value "foo" # => Example::A
```

Mapped values may also be extracted
```crystal
Example::A.mapped_value # => "foo"
```

All other functionality and safety that enums provide holds.


### `presence`

Provides `Object#presence`.

This Allows one to check for the presence of useful data in container types such as `Array` and `Hash`.

```crystal
# hash loaded from config file or database
# imagine this is `Hash(String, String) | Nil`
my_hash = {} of String => String

# set some defaults
my_hash = my_hash.presence || {"default" => "settings"}
```

### `with_default`

Provides `Hash(K,V).with_default`

Creates a `Hash(K,V)` with a default for missing keys with the result of a yielded block.
Includes a pun of `Hash(K,V).new(default_value : V, initial_capacity = nil)`

```crystal
require "inactive-support/with_default/hash"
# or...
# require "inactive-support/with_default"

block_default = Hash(String, Array(Int32).with_default { ["bye"] }
block_default.empty? # => true
block_default["hello"] # => ["bye"]
block_default["a"] == block_default["b"] # => false

value_default = Hash(String, Array(Int32).with_default ["bye"]
value_default.empty? # => true
value_default["hello"] # => ["bye"]
value_default["a"] == value_default["b"] # => true
```
