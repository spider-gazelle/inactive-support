require "spec"
require "../../src/mapped_enum"

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

SpecMappedEnumLookupTest = "foo"

describe "macro/mapped_enum" do
  it "defines an enum type" do
    (SpecMappedEnum < Enum).should be_true
  end

  it "places instance methods in the created type" do
    SpecMappedEnum::A.instance_test.should eq "hello"
  end

  it "places class methods in the created type" do
    SpecMappedEnum.class_test.should eq 42
  end

  describe "[]" do
    it "provides compile-time resolution from a direct value" do
      SpecMappedEnum["foo"].should eq SpecMappedEnum::A
    end

    it "provides compile-time resolution from a resolvable Path" do
      SpecMappedEnum[SpecMappedEnumLookupTest].should eq SpecMappedEnum::A
    end
  end

  describe Enum do
    describe ".mapped_values" do
      it "provides a Tuple of mapped values" do
        SpecMappedEnum.mapped_values.should eq({"foo", "bar", "baz"})
      end
    end

    describe ".from_mapped_value" do
      it "reads into a known mapped value" do
        SpecMappedEnum.from_mapped_value("foo").should eq SpecMappedEnum::A
      end

      it "raises if no matching member exists and no block is passed" do
        expect_raises(Exception) do
          SpecMappedEnum.from_mapped_value("qux")
        end
      end
    end

    describe ".from_mapped_value?" do
      it "reads into a known mapped value" do
        SpecMappedEnum.from_mapped_value?("foo").should eq SpecMappedEnum::A
      end

      it "returns nil if no matching member exists" do
        SpecMappedEnum.from_mapped_value?("qux").should be_nil
      end
    end

    describe "#mapped_value" do
      it "returns the mapped value" do
        SpecMappedEnum::A.mapped_value.should eq "foo"
      end
    end
  end
end
