require "spec"
require "../../src/with_default/hash"

describe "with_default/hash" do
  describe "Hash(K,V).with_default" do
    it "creates defaults for missing keys with a value" do
      hash = Hash(String, Int32).with_default(5)
      hash.should be_empty
      hash["1"].should eq 5
    end

    it "creates defaults for missing keys with a block" do
      hash = Hash(String, Array(Int32)).with_default { [] of Int32 }
      hash.should be_empty
      array1 = hash["1"]
      array2 = hash["2"]
      array1.should_not be array2
    end
  end
end
