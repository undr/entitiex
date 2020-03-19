defmodule Entitiex.ExposureTest do
  use ExUnit.Case

  alias Entitiex.Exposure
  alias Entitiex.Entity

  defmodule Test1 do
    defstruct [x: "value"]

    def attr_name(_) do
      "func value"
    end
  end

  defmodule Test1Entity do
    use Entity

    expose :x, as: :y

    def attr_name_1(_) do
      "func with arity 1"
    end

    def attr_name_2(_, _) do
      "func with arity 2"
    end

    def attr_name_3(_, _, _) do
      "func with arity 3"
    end
  end

  defmodule Test2Entity do
    use Entity

    format_keys :to_s

    def custom_formatter(value) do
      "#{value}_formatted"
    end
  end

  def setup_exposure(%{entity: entity, opts: opts, key: key}) do
    Exposure.new(entity, key, opts)
  end

  def setup_exposure(%{entity: entity, opts: opts}) do
    Exposure.new(entity, :attr_name, opts)
  end

  setup(context) do
    {:ok, exposure: setup_exposure(context)}
  end

  describe "key" do
    @tag entity: Test1Entity, opts: []
    test "without global key formatter and opts", %{exposure: exposure} do
      assert(Exposure.key(exposure) == :attr_name)
    end

    @tag entity: Test1Entity, opts: [as: :key_alias]
    test "without global key formatter and with alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == :key_alias)
    end

    @tag entity: Test2Entity, opts: []
    test "without opts", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "attr_name")
    end

    @tag entity: Test2Entity, opts: [as: :key_alias]
    test "with alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "key_alias")
    end

    @tag entity: Test2Entity, opts: [format_key: :custom_formatter]
    test "with format", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "attr_name_formatted")
    end

    @tag entity: Test2Entity, opts: [as: :key_alias, format_key: :custom_formatter]
    test "with format and alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "key_alias_formatted")
    end
  end

  describe "value" do
    @tag entity: Test1Entity, opts: []
    test "without opts", %{exposure: exposure} do
      assert(Exposure.value(exposure, %{attr_name: "value"}) == {:put, "value"})
    end

    @tag entity: Test1Entity, opts: []
    test "from struct function", %{exposure: exposure} do
      assert(Exposure.value(exposure, %Test1{}) == {:put, "func value"})
    end

    @tag entity: Test1Entity, opts: [], key: :attr_name_1
    test "from entity function with arity 1", %{exposure: exposure} do
      assert(Exposure.value(exposure, %Test1{}) == {:put, "func with arity 1"})
    end

    @tag entity: Test1Entity, opts: [], key: :attr_name_2
    test "from entity function with arity 2", %{exposure: exposure} do
      assert(Exposure.value(exposure, %Test1{}) == {:put, "func with arity 2"})
    end

    @tag entity: Test1Entity, opts: [], key: :attr_name_3
    test "from entity function with arity 3", %{exposure: exposure} do
      assert(Exposure.value(exposure, %Test1{}, %{}) == {:put, "func with arity 3"})
    end

    @tag entity: Test1Entity, opts: [], key: nil
    test "without key", %{exposure: exposure} do
      assert(Exposure.value(exposure, %{x: "value"}) == {:put, %{x: "value"}})
    end

    @tag entity: Test2Entity, opts: [using: Test1Entity]
    test "with using", %{exposure: exposure} do
      assert(Exposure.value(exposure, %{attr_name: %{x: "value"}}) == {:put, %{y: "value"}})
    end

    @tag entity: Test2Entity, opts: [using: Test1Entity, merge: true]
    test "with using and merge", %{exposure: exposure} do
      assert(Exposure.value(exposure, %{attr_name: %{x: "value"}}) == {:merge, %{y: "value"}})
    end

    @tag entity: Test1Entity, opts: [merge: true]
    test "with merge", %{exposure: exposure} do
      assert(Exposure.value(exposure, %{attr_name: %{x: "value"}}) == {:merge, %{x: "value"}})
    end

    @tag entity: Test2Entity, opts: [format: :custom_formatter]
    test "with atom formatter", %{exposure: exposure} do
      assert(Exposure.value(exposure, %{attr_name: "value"}) == {:put, "value_formatted"})
    end

    @tag entity: Test2Entity, opts: [format: &Test2Entity.custom_formatter/1]
    test "with func formatter", %{exposure: exposure} do
      assert(Exposure.value(exposure, %{attr_name: "value"}) == {:put, "value_formatted"})
    end
  end
end
