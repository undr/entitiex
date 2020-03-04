defmodule Entitiex.UtilsTest do
  use ExUnit.Case

  alias Entitiex.Utils

  defmodule Formats do
    def reverse(key) do
      key |> to_string |> String.reverse
    end
  end

  describe "transform_keys" do
    test "keywords" do
      assert(Utils.transform_keys([xyz: "XYZ", abc: "ABC"], &Formats.reverse/1) == %{"zyx" => "XYZ", "cba" => "ABC"})
    end

    test "keywords with nested keywords" do
      assert(
        Utils.transform_keys([xyz: "XYZ", abc: [cba: "ABC"]], &Formats.reverse/1) ==
          %{"zyx" => "XYZ", "cba" => %{"abc" => "ABC"}}
      )
    end

    test "keywords with nested maps" do
      assert(
        Utils.transform_keys([xyz: "XYZ", abc: %{cba: "ABC"}], &Formats.reverse/1) ==
          %{"zyx" => "XYZ", "cba" => %{"abc" => "ABC"}}
      )
    end

    test "keywords with nested list" do
      assert(
        Utils.transform_keys([xyz: "XYZ", abc: [1, [cba: "ABC"], 3]], &Formats.reverse/1) ==
          %{"zyx" => "XYZ", "cba" => [1, %{"abc" => "ABC"}, 3]}
      )
    end

    test "maps" do
      assert(Utils.transform_keys(%{xyz: "XYZ", abc: "ABC"}, &Formats.reverse/1) == %{"zyx" => "XYZ", "cba" => "ABC"})
    end

    test "maps with nested maps" do
      assert(
        Utils.transform_keys(%{xyz: "XYZ", abc: %{cba: "ABC"}}, &Formats.reverse/1) ==
          %{"zyx" => "XYZ", "cba" => %{"abc" => "ABC"}}
      )
    end

    test "maps with nested keywords" do
      assert(
        Utils.transform_keys(%{xyz: "XYZ", abc: [cba: "ABC"]}, &Formats.reverse/1) ==
          %{"zyx" => "XYZ", "cba" => %{"abc" => "ABC"}}
      )
    end

    test "maps with nested list" do
      assert(
        Utils.transform_keys(%{xyz: "XYZ", abc: [1, %{cba: "ABC"}, 3]}, &Formats.reverse/1) ==
          %{"zyx" => "XYZ", "cba" => [1, %{"abc" => "ABC"}, 3]}
      )
    end
  end
end
