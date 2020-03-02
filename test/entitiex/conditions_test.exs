defmodule Entitiex.ConditionsTest do
  use ExUnit.Case

  alias Entitiex.Conditions

  defmodule Test do
    def should_expose?(_struct, value),
      do: "expose me" == value

    def should_expose_with_extra?(_struct, _value, extra),
      do: extra

    def should_always_expose?(_struct, _value),
      do: true
  end

  test "compile" do
    assert Conditions.compile([]) == [&Conditions.expose_nil?/2]
    assert Conditions.compile([expose_nil: false]) == [&Conditions.expose_nil?/2]
    assert Conditions.compile([expose_nil: true]) == []
    assert Conditions.compile([if: &Test.should_expose?/2]) == [&Conditions.expose_nil?/2, &Test.should_expose?/2]
    assert Conditions.compile([if: {Test, :should_expose?}]) == [&Conditions.expose_nil?/2, {Test, :should_expose?, []}]
    assert Conditions.compile([if: {Test, :should_expose?, []}]) == [&Conditions.expose_nil?/2, {Test, :should_expose?, []}]
  end

  test "run" do
    assert Conditions.run([{Test, :should_expose?, []}], %{}, "expose me")
    refute Conditions.run([{Test, :should_expose?, []}], %{}, "do not expose me")
    assert Conditions.run([&Test.should_expose?/2], %{}, "expose me")
    refute Conditions.run([&Test.should_expose?/2], %{}, "do not expose me")
    assert Conditions.run([{Test, :should_expose_with_extra?, [true]}], %{}, "expose me")
    refute Conditions.run([{Test, :should_expose_with_extra?, [false]}], %{}, "do not expose me")
    refute Conditions.run([&Conditions.expose_nil?/2, &Test.should_always_expose?/2], %{}, nil)
    assert Conditions.run([&Conditions.expose_nil?/2, &Test.should_always_expose?/2], %{}, "expose me")
  end
end
