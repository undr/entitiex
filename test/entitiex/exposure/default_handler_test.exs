defmodule Entitiex.Exposure.DefaultHandlerTest do
  use ExUnit.Case

  alias Entitiex.Exposure.DefaultHandler

  defmodule Model do
    defstruct [x: 0, y: 0]

    def coords(struct) do
      [struct.x, struct.y]
    end
  end

  defmodule Test do
    use Entitiex.Entity
  end

  defmodule TestX do
    use Entitiex.Entity

    format_keys :to_s
    format_keys :reverse

    def x(_struct) do
      "calculated value"
    end

    def y(_struct, attr) do
      "calculated value for #{attr}"
    end

    def reverse(value) do
      String.reverse(value)
    end
  end

  describe "value" do
    test "when model has function with arity 1" do
      exposure = %Entitiex.Exposure{attribute: :coords, entity: TestX}
      assert(DefaultHandler.value(exposure, %Model{}) == [0, 0])
      assert(DefaultHandler.value(exposure, %Model{x: 1, y: 2}) == [1, 2])
    end

    test "when serializer has function with arity 1" do
      exposure = %Entitiex.Exposure{attribute: :x, entity: TestX}
      assert(DefaultHandler.value(exposure, %{}) == "calculated value")
      assert(DefaultHandler.value(exposure, %{x: nil}) == "calculated value")
      assert(DefaultHandler.value(exposure, %{x: "value"}) == "calculated value")
    end

    test "when serializer has function with arity 2" do
      exposure = %Entitiex.Exposure{attribute: :y, key: :y0, entity: TestX}
      assert(DefaultHandler.value(exposure, %{}) == "calculated value for y0")
      assert(DefaultHandler.value(exposure, %{y: nil}) == "calculated value for y0")
      assert(DefaultHandler.value(exposure, %{y: "value"}) == "calculated value for y0")
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
    assert(DefaultHandler.setup(:Any, []) == {DefaultHandler, []})
  end
end
