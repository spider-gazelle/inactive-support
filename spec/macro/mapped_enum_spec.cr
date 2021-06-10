require "spec"
require "../../src/macro/mapped_enum"

mapped_enum SpecStrictMappedEnum(String),
  A = "foo",
  B = "bar",
  C = "baz"

mapped_enum SpecMappedEnum,
  A = "foo",
  B = "bar",
  C = "baz"

describe "macro/mapped_enum" do
  {% for type in [SpecStrictMappedEnum, SpecMappedEnum] %}
    describe {{type.stringify}} do
      it "defines an enum type" do
        ({{type}} < Enum).should be_true
      end

      describe ".from_mapped_value" do
        it "reads into a known mapped value" do
          {{type}}.from_mapped_value("foo").should eq {{type}}::A
        end

        it "yields if no matching member exists" do
          yielded = false
          result = {{type}}.from_mapped_value("qux") do
            yielded = true
            {{type}}::A
          end
          yielded.should be_true
          result.a?.should be_true
        end

        it "raises if no matching member exists and no block is passed" do
          expect_raises(Exception) do
            {{type}}.from_mapped_value("qux")
          end
        end
      end

      describe ".[]" do
        it "reads into a known mapped value" do
          {{type}}["foo"].should eq {{type}}::A
        end

        it "raises if no matching member exists and no block is passed" do
          expect_raises(Exception) do
            {{type}}["qux"]
          end
        end
      end

      describe ".from_mapped_value?" do
        it "reads into a known mapped value" do
          {{type}}.from_mapped_value?("foo").should eq {{type}}::A
        end

        it "returns nil if no matching member exists" do
          {{type}}.from_mapped_value?("qux").should be_nil
        end
      end

      describe ".[]?" do
        it "reads into a known mapped value" do
          {{type}}["foo"]?.should eq {{type}}::A
        end

        it "returns nil if no matching member exists" do
          {{type}}["qux"]?.should be_nil
        end
      end

      describe ".mapped_values" do
        it "provides a Tuple of mapped values" do
          {{type}}.mapped_values.should eq({"foo", "bar", "baz"})
        end
      end

      describe "#mapped_value" do
        it "returns the mapped value" do
          {{type}}::A.mapped_value.should eq "foo"
        end
      end

      describe "#~" do
        it "returns the mapped value" do
          (~{{type}}::A).should eq "foo"
        end
      end
    end
  {% end %}
end
