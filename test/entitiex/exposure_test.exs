defmodule Entitiex.ExposureTest do
  use ExUnit.Case

  alias Entitiex.Exposure

  defmodule TestEntity do
    use Entitiex.Entity

    format_keys :to_s

    def custom_formatter(value) do
      "#{value}_formatted"
    end
  end

  setup %{entity: entity, opts: opts} do
    exposure = Exposure.new(entity, :attr_name, opts)
    {:ok, exposure: exposure}
  end

  describe "key" do
    @tag entity: TestEntity, opts: []
    test "without opts", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "attr_name")
    end

    @tag entity: TestEntity, opts: [as: :key_alias]
    test "with alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "key_alias")
    end

    @tag entity: TestEntity, opts: [format_key: :custom_formatter]
    test "with format", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "attr_name_formatted")
    end

    @tag entity: TestEntity, opts: [as: :key_alias, format_key: :custom_formatter]
    test "with format and alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "key_alias_formatted")
    end
  end
end
