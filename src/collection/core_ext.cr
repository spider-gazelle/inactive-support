require "json"
require "yaml"
require "http"
require "uri"
require "./collection"

module Indexable(T)
  include Collection(Int32, T)

  def each_pair(&block) : Nil
    each_with_index { |e, i| yield({i, e}) }
  end

  def each_pair : Iterator({Int32, T})
    each.with_index.map { |(e, i)| {i, e} }
  end
end

struct NamedTuple(T)
  # FIXME: the co-domain should be a `Union(T.values)`, however this is not
  # expressable with the current compiler.
  # See: https://github.com/crystal-lang/crystal/issues/6757
  include Collection(Symbol, NoReturn)

  def each_pair(&block) : Nil
    each { |k, v| yield({k, v}) }
  end

  def each_pair : Iterator
    to_a.each
  end
end

class Hash(K, V)
  include Collection(K, V)

  def each_pair(&block) : Nil
    each { |k, v| yield({k, v}) }
  end

  def each_pair : Iterator({K, V})
    each
  end
end

struct JSON::Any
  include Collection(String | Int32, JSON::Any)

  def each_pair(&block) : Nil
    if value = as_h? || as_a?
      value.each_pair { |k, v| yield({k, v}) }
    end
  end

  protected def nested? : Bool
    !(as_h? || as_a?).nil?
  end
end

struct YAML::Any
  include Collection(String | Int32, YAML::Any)

  def each_pair(&block) : Nil
    if value = as_a?
      value.each_pair { |k, v| yield({k, v}) }
    elsif value = as_h?
      value.each_pair { |k, v| yield({k.to_s, v}) }
    end
  end

  protected def nested? : Bool
    !(as_h? || as_a?).nil?
  end
end

class HTTP::Cookies
  include Collection(String, HTTP::Cookie)

  def each_pair(&block) : Nil
    each { |c| yield({c.name, c}) }
  end

  def each_pair
    each.map { |c| ({c.name, c}) }
  end
end

struct HTTP::Headers
  include Collection(String, Array(String))

  def each_pair(&block) : Nil
    each { |k, v| yield({k, v}) }
  end

  def each_pair : Iterator({String, Array(String)})
    each
  end
end

struct URI::Params
  include Collection(String, String)

  def each_pair(&block) : Nil
    each { |k, v| yield({k, v}) }
  end

  def each_pair : Iterator({String, String})
    each
  end
end
