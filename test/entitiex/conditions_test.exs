defmodule Entitiex.ConditionsTest do
  use ExUnit.Case

  alias Entitiex.Conditions

  defmodule Test do
    def should_expose?(_struct, value),
      do: "expose me" == value

    def should_expose3?(_struct, _value, %{expose: expose}),
      do: expose
    def should_expose3?(_struct, _value, _context),
      do: false

    def should_always_expose?(_struct, _value),
      do: true
  end

  test "compile" do
    assert Conditions.compile(Test, []) == []
    assert Conditions.compile(Test, [expose_nil: false]) == [&Conditions.expose_nil?/2]
    assert Conditions.compile(Test, [expose_nil: true]) == []
    assert Conditions.compile(Test, [if: &Test.should_expose?/2]) == [&Test.should_expose?/2]
    assert Conditions.compile(Test, [if: :should_expose?]) == [&Test.should_expose?/2]
    assert Conditions.compile(Test, [if: :should_expose?, expose_nil: false]) == [&Conditions.expose_nil?/2, &Test.should_expose?/2]
    assert Conditions.compile(Test, [if: :should_expose3?]) == [&Test.should_expose3?/3]
    assert Conditions.compile(Test, [if: :should_expose3?, expose_nil: false]) == [&Conditions.expose_nil?/2, &Test.should_expose3?/3]
  end

  test "run" do
    assert Conditions.run([&Test.should_expose?/2], %{}, "expose me")
    refute Conditions.run([&Test.should_expose?/2], %{}, "do not expose me")
    refute Conditions.run([&Conditions.expose_nil?/2, &Test.should_always_expose?/2], %{}, nil)
    assert Conditions.run([&Conditions.expose_nil?/2, &Test.should_always_expose?/2], %{}, "expose me")
    assert Conditions.run([&Test.should_expose3?/3], %{}, "anything", %{expose: true})
    refute Conditions.run([&Test.should_expose3?/3], %{}, "anything", %{expose: false})
    refute Conditions.run([&Test.should_expose3?/3], %{}, "anything", %{})
  end
end
