defmodule Entitiex.Exposure.DefaultHandlerTest do
  use ExUnit.Case

  alias Entitiex.Exposure.DefaultHandler

  defmodule Test do
    use Entitiex.Entity
  end

  defmodule TestX do
    use Entitiex.Entity

    format_with :reverse, &String.reverse/1

    format_keys :to_s
    format_keys :reverse

    def x(struct) do
      case Map.get(struct, :x) do
        nil -> "null"
        any -> "calculated #{any}"
      end
    end
  end

  describe "value" do
    test "when serializer has function" do
      exposure = %Entitiex.Exposure{attribute: :x, entity: TestX}
      assert(DefaultHandler.value(exposure, %{}) == "null")
      assert(DefaultHandler.value(exposure, %{x: nil}) == "null")
      assert(DefaultHandler.value(exposure, %{x: "value"}) == "calculated value")
    end

    test "when serializer does not have function" do
      exposure = %Entitiex.Exposure{attribute: :x, entity: Test}
      assert(DefaultHandler.value(exposure, %{}) == nil)
      assert(DefaultHandler.value(exposure, %{x: nil}) == nil)
      assert(DefaultHandler.value(exposure, %{x: "value"}) == "value")
    end
  end

  describe "key" do
    test "without default formatter" do
      exposure = %Entitiex.Exposure{entity: Test}
      assert(DefaultHandler.key(exposure, :entity_key) == :entity_key)
    end

    test "with default formatter" do
      exposure = %Entitiex.Exposure{entity: TestX}
      assert(DefaultHandler.key(exposure, :entity_key) == "yek_ytitne")
    end
  end

  test "setup" do
    assert(DefaultHandler.setup([]) == {DefaultHandler, []})
  end
end
