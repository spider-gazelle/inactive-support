require "spec"
require "../../src/macro/args"

def args_test(a, b, c)
  args
end

describe "macro/args" do
  it "creates a NamedTuple from surround args" do
    result = args_test "foo", "bar", "baz"
    result.should eq({a: "foo", b: "bar", c: "baz"})
  end
end

