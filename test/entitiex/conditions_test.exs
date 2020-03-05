defmodule Entitiex.ConditionsTest do
  use ExUnit.Case

  alias Entitiex.Conditions

  defmodule Test do
    def should_expose?(_struct, value),
      do: "expose me" == value

    def should_always_expose?(_struct, _value),
      do: true
  end

  test "compile" do
    assert Conditions.compile(Test, []) == [&Conditions.expose_nil?/2]
    assert Conditions.compile(Test, [expose_nil: false]) == [&Conditions.expose_nil?/2]
    assert Conditions.compile(Test, [expose_nil: true]) == []
    assert Conditions.compile(Test, [if: &Test.should_expose?/2]) == [&Conditions.expose_nil?/2, &Test.should_expose?/2]
    assert Conditions.compile(Test, [if: :should_expose?]) == [&Conditions.expose_nil?/2, &Test.should_expose?/2]
    assert Conditions.compile(Test, [if: :should_expose?, expose_nil: true]) == [&Test.should_expose?/2]
  end

  test "run" do
    assert Conditions.run([&Test.should_expose?/2], %{}, "expose me")
    refute Conditions.run([&Test.should_expose?/2], %{}, "do not expose me")
    refute Conditions.run([&Conditions.expose_nil?/2, &Test.should_always_expose?/2], %{}, nil)
    assert Conditions.run([&Conditions.expose_nil?/2, &Test.should_always_expose?/2], %{}, "expose me")
  end
end
