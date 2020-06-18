require "spec"
require "../src/collection"

describe Collection do
  describe "#[]?" do
    context Array do
      collection = [42].as Collection(Int32, Int32)

      it "provides entries by index" do
        collection[0]?.should eq(42)
      end

      it "returns nil for invalid indicies" do
        collection[999]?.should be_nil
      end
    end

    context Hash do
      it "provides the element when it exists" do
        collection = {:foo => 42}.as Collection(Symbol, Int32)
        collection[:foo]?.should eq(42)
      end
    end

    context JSON::Any do
      it "provides the element" do
        collection = JSON.parse({foo: 42}.to_json).as Collection(String | Int32, JSON::Any)
        collection["foo"]?.should eq(42)
      end
    end
  end

  describe "#[]" do
    context Hash do
      collection = {:foo => 42}.as Collection(Symbol, Int32)

      it "provides the element when it exists" do
        collection[:foo].should eq(42)
      end

      it "raises on invalid key" do
        expect_raises(KeyError) do
          collection[:bar]
        end
      end
    end
  end

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
        c: {"hello" => "world"},
      }
      array = [] of NoReturn
      nested.each_pair { |pair| array = array + Array.new(1, pair) }
      array.should eq(nested.to_a)
    end

    it "provides an iterator when called without a block" do
      context Array do
        array = [:foo, :bar, :baz].each_pair.to_a
        array.should eq([{0, :foo}, {1, :bar}, {2, :baz}])
      end

      context NamedTuple do
        array = {a: 1, b: 2, c: 3}.each_pair.to_a
        array.should eq([{:a, 1}, {:b, 2}, {:c, 3}])
      end
    end
  end

  describe "#nested?" do
    it "returns false for a flat structure" do
      [:foo, :bar, :baz].nested?.should be_false
    end

    it "returns to for a nested structure" do
      [[:foo]].nested?.should be_true
    end

    it "returns true when only some elements are nested" do
      {:foo, [1, 2, 3]}.nested?.should be_true
    end
  end

  describe "#traverse" do
    nested = {
      a: 42,
      b: [:foo, :bar, :baz],
      c: {"hello" => "world"},
    }

    flat = {
      {:a}          => 42,
      {:b, 0}       => :foo,
      {:b, 1}       => :bar,
      {:b, 2}       => :baz,
      {:c, "hello"} => "world",
    }

    it "yields tuples of path, value for nested structures" do
      flattened = {} of NoReturn => NoReturn
      nested.traverse do |(path, value)|
        flattened = flattened.merge({path => value})
      end
      flattened.should eq(flat)
    end

    it "provides an iterator of all leafs values in the nested structure" do
      flattened = nested.traverse.to_h
      flattened.should eq(flat)
    end

    it "supports recursive types" do
      flat = {
        ["a"]          => 42,
        ["b", 0]       => "foo",
        ["b", 1]       => "bar",
        ["b", 2]       => "baz",
        ["c", "hello"] => "world",
      }

      {% for type in {JSON, YAML} %}
        context {{type}} do
          parsed = {{type}}.parse nested.to_{{type.id.downcase}}
          parsed.traverse.to_h.should eq(flat)
        end
      {% end %}
    end
  end
end
