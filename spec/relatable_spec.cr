require "spec"
require "../src/relatable"

describe Relatable do
  describe "#each_pair" do
    it "yields index, element pairs to a block" do
      array = [] of {Int32, Symbol}
      [:foo, :bar, :baz].each_pair { |pair| array << pair }
      array.should eq([{0, :foo}, {1, :bar}, {2, :baz}])
    end

    it "yields key, value pairs to a block" do
      array = [] of {Symbol, Int32}
      {a: 1, b: 2, c: 3}.each_pair { |pair| array << pair }
      array.should eq([{:a, 1}, {:b, 2}, {:c, 3}])
    end

    it "yields only the current level of nesting" do
      nested = {
        a: 42,
        b: [:foo, :bar, :baz],
        c: {"hello" => "world"}
      }
      array = [] of NoReturn
      nested.each_pair { |pair| array = array + Array.new(1, pair) }
      array.should eq(nested.to_a)
    end
  end

  describe "#traverse" do
    it "yields tuples of path, value for nested structures" do
      nested = {
        a: 42,
        b: [:foo, :bar, :baz],
        c: {"hello" => "world"}
      }
      flattened = {} of NoReturn => NoReturn
      nested.traverse do |(path, value)|
        flattened = flattened.merge({path => value})
      end
      flattened.should eq({
        {:a} => 42,
        {:b, 0} => :foo,
        {:b, 1} => :bar,
        {:b, 2} => :baz,
        {:c, "hello"} => "world"
      })
    end
  end
end
