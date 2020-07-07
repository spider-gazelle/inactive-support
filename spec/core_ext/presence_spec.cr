require "spec"
require "../../src/core_ext/presence"

describe "core_ext/presence" do
  it "checks for presence of data in objects" do
    nil.present?.should eq nil
    Array(String).new.present?.should eq nil
    Hash(String, String).new.present?.should eq nil

    1234.present?.should eq 1234
    [1, 2, 3].present?.should eq [1, 2, 3]
    {"test" => "data"}.present?.should eq({"test" => "data"})
  end

  it "checks whitespace in strings" do
    "".present?.should eq nil
    "  ".present?.should eq nil
    "   \t\n  \n".present?.should eq nil
    "  data ".present?.should eq "  data "
  end
end
