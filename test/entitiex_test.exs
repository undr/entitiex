defmodule EntitiexTest do
  use ExUnit.Case

  test "default_formatters" do
    assert is_list(Entitiex.default_formatters())
    assert Keyword.keys(Entitiex.default_formatters()) == [:to_s, :to_atom, :camelize, :lcamelize]
  end
end
