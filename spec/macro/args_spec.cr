require "spec"
require "../../src/macro/args"

def args_test(a, b, c)
  args
end

def args_test2(d, **e)
  args
end

describe "macro/args" do
  it "creates a NamedTuple from surround args" do
    result = args_test "foo", "bar", "baz"
    result.should eq({a: "foo", b: "bar", c: "baz"})
  end

  it "includes the double splat arg if it exists" do
    result = args_test2 "test", hello: "world"
    result.should eq({d: "test", e: {hello: "world"}})
  end
end
