defmodule Entitiex.Exposure.EntityHandlerTest do
  use ExUnit.Case

  alias Entitiex.Exposure.EntityHandler

  defmodule Test do
    use Entitiex.Entity

    expose :x
    expose :y
  end

  describe "value" do
    test "when using option is defined" do
      exposure = %Entitiex.Exposure{opts: [using: Test]}
      assert(EntityHandler.value(exposure, nil) == nil)
      assert(EntityHandler.value(exposure, %{}) == %{})
      assert(EntityHandler.value(exposure, %{x: "x", y: "y", z: "z"}) == %{x: "x", y: "y"})
      assert(EntityHandler.value(exposure, [%{x: "x", y: "y", z: "z"}]) == [%{x: "x", y: "y"}])
    end

    test "when using option is not defined" do
      exposure = %Entitiex.Exposure{opts: []}
      assert(EntityHandler.value(exposure, nil) == nil)
      assert(EntityHandler.value(exposure, %{}) == nil)
      assert(EntityHandler.value(exposure, %{x: "x", y: "y", z: "z"}) == nil)
      assert(EntityHandler.value(exposure, [%{x: "x", y: "y", z: "z"}]) == nil)
    end
  end

  test "key" do
    assert(EntityHandler.key(%Entitiex.Exposure{}, :entity_key) == :entity_key)
  end

  test "setup" do
    assert(EntityHandler.setup(:Any, []) == nil)
    assert(EntityHandler.setup(:Any, [using: Test]) == {EntityHandler, [using: Test]})
  end
end
