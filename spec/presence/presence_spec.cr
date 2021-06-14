require "spec"
require "../../src/presence"

describe "core_ext/presence" do
  it "checks for presence of data in objects" do
    nil.presence.should eq nil
    Array(String).new.presence.should eq nil
    Hash(String, String).new.presence.should eq nil

    1234.presence.should eq 1234
    [1, 2, 3].presence.should eq [1, 2, 3]
    {"test" => "data"}.presence.should eq({"test" => "data"})
  end

  it "checks whitespace in strings" do
    "".presence.should eq nil
    "  ".presence.should eq nil
    "   \t\n  \n".presence.should eq nil
    "  data ".presence.should eq "  data "
  end

  it "works with union types" do
    me = 3
    object = case me
             when 1
               "  some stry "
             when 2
               [1, 2, 3, 4]
             when 3
               {1, 2, 3}
             when 4
               {"me" => 123}
             end

    typeof(object).to_s.should eq("(Array(Int32) | Hash(String, Int32) | String | Tuple(Int32, Int32, Int32) | Nil)")
    (!!object.presence).should eq(true)
  end
end
