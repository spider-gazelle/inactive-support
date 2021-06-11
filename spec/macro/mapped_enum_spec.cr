require "spec"
require "../../src/macro/mapped_enum"

mapped_enum SpecMappedEnum do
  A = "foo"
  B = "bar"
  C = "baz"

  def instance_test
    "hello"
  end

  def self.class_test
    42
  end
end

describe "macro/mapped_enum" do
  it "defines an enum type" do
    (SpecMappedEnum < Enum).should be_true
  end

  describe ".[]" do
    it "reads into a known mapped value" do
      SpecMappedEnum["foo"].should eq SpecMappedEnum::A
    end

    it "raises if no matching member exists and no block is passed" do
      expect_raises(Exception) do
        SpecMappedEnum["qux"]
      end
    end
  end

  describe ".[]?" do
    it "reads into a known mapped value" do
      SpecMappedEnum["foo"]?.should eq SpecMappedEnum::A
    end

    it "returns nil if no matching member exists" do
      SpecMappedEnum["qux"]?.should be_nil
    end
  end

  describe ".mapped_values" do
    it "provides a Tuple of mapped values" do
      SpecMappedEnum.mapped_values.should eq(["foo", "bar", "baz"])
    end
  end

  describe "#mapped_value" do
    it "returns the mapped value" do
      SpecMappedEnum::A.mapped_value.should eq "foo"
    end
  end

  it "places instance methods in the created type" do
    SpecMappedEnum::A.instance_test.should eq "hello"
  end

  it "places class method in the created type" do
    SpecMappedEnum.class_test.should eq 42
  end
end
