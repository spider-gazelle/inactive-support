# Inactive Support

A collection of utility classes, macros and standard library extensions to simplify common tasks in crystal-lang.

Each tool is small, independent and generic.
To use a tool, explicitly `require` where needed.
Their usage should be highly intentional and not a default choice.


## Usage

### Object#presence

Allows one to check for the presence of useful data in container types such as
`Array` and `Hash`

```
# hash loaded from config file or database
# imagine this is `Hash(String, String) | Nil`
my_hash = {} of String => String

# set some defaults
my_hash = my_hash.presence || {"default" => "settings"}

```


## Contributors

- [Kim Burgess](https://github.com/KimBurgess) - creator and maintainer
