defmodule Entitiex.NormalizerTest do
  use ExUnit.Case

  alias Entitiex.Normalizer

  defmodule TestResolver do
    def formatter1(_value) do
    end

    def condition2(_struct, _value) do
    end

    def condition3(_struct, _value, _context) do
    end
  end

  describe "normalize" do
    test 'normalize formatter functions' do
      assert Normalizer.normalize(:formatter, :to_s, TestResolver) == [&Entitiex.Formatter.to_s/1]
      assert Normalizer.normalize(:formatter, :formatter1, TestResolver) == [&TestResolver.formatter1/1]
      assert Normalizer.normalize(:formatter, [:to_s, :formatter1], TestResolver) == [&Entitiex.Formatter.to_s/1, &TestResolver.formatter1/1]
      assert_raise RuntimeError, "Formatter function is not found (:formatter2 or Entitiex.NormalizerTest.TestResolver.formatter2/1)", fn ->
        Normalizer.normalize(:formatter, :formatter2, TestResolver)
      end
      assert_raise RuntimeError, ~r/Formatter function is not found/, fn ->
        Normalizer.normalize(:formatter, :formatter2, TestResolver)
      end
    end

    test 'normalize condition functions' do
      assert Normalizer.normalize(:condition, :condition2, TestResolver) == [&TestResolver.condition2/2]
      assert Normalizer.normalize(:condition, :condition3, TestResolver) == [&TestResolver.condition3/3]
      assert Normalizer.normalize(:condition, [:condition2, :condition3], TestResolver) == [&TestResolver.condition2/2, &TestResolver.condition3/3]
      assert_raise RuntimeError, ~r/Condition function is not found/, fn ->
        Normalizer.normalize(:condition, :condition5, TestResolver)
      end
    end
  end
end
