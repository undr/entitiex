defmodule Entitiex.Exposure.FormatterTest do
  use ExUnit.Case

  alias Entitiex.Exposure.Formatter

  test "to_s" do
    assert Formatter.to_s(100) == "100"
    assert Formatter.to_s(100.05) == "100.05"
    assert Formatter.to_s("string") == "string"
    assert Formatter.to_s(:atom) == "atom"
    assert Formatter.to_s([1, 1.2, "string", :atom]) == ["1", "1.2", "string", "atom"]
  end

  test "to_atom" do
    assert Formatter.to_atom(100) == :"100"
    assert Formatter.to_atom(100.05) == :"100.05"
    assert Formatter.to_atom("string") == :string
    assert Formatter.to_atom(:atom) == :atom
    assert Formatter.to_atom([1, 1.2, "string", :atom]) == [:"1", :"1.2", :string, :atom]
  end

  test "camelize" do
    assert Formatter.camelize(:atom_key) == "AtomKey"
    assert Formatter.camelize(:AtomKey) == "AtomKey"
    assert Formatter.camelize("string_key") == "StringKey"
    assert Formatter.camelize("StringKey") == "StringKey"
    assert Formatter.camelize([:atom_key, "string_key"]) == ["AtomKey", "StringKey"]
  end

  test "lcamelize" do
    assert Formatter.lcamelize(:atom_key) == "atomKey"
    assert Formatter.lcamelize(:AtomKey) == "atomKey"
    assert Formatter.lcamelize("string_key") == "stringKey"
    assert Formatter.lcamelize("StringKey") == "stringKey"
    assert Formatter.lcamelize([:atom_key, "string_key"]) == ["atomKey", "stringKey"]
  end
end
