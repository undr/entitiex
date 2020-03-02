defmodule Entitiex.Exposure.EntityHandlerTest do
  use ExUnit.Case

  alias Entitiex.Exposure.EntityHandler

  defmodule Test do
    use Entitiex.Entity

    expose :x
    expose :y
  end

  describe "value" do
    test "when nested is defined" do
      exposure = %Entitiex.Exposure{opts: [nested: Test]}
      assert(EntityHandler.value(exposure, nil) == nil)
      assert(EntityHandler.value(exposure, %{}) == %{})
      assert(EntityHandler.value(exposure, %{x: "x", y: "y", z: "z"}) == %{x: "x", y: "y"})
      assert(EntityHandler.value(exposure, [%{x: "x", y: "y", z: "z"}]) == [%{x: "x", y: "y"}])
    end

    test "when nested is not defined" do
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
    assert(EntityHandler.setup([]) == nil)
    assert(EntityHandler.setup([using: Test]) == {EntityHandler, [nested: Test, merge: false]})
    assert(EntityHandler.setup([using: Test, merge: true]) == {EntityHandler, [nested: Test, merge: true]})
  end
end
