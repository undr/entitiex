defmodule Entitiex.ExposureTest do
  use ExUnit.Case

  alias Entitiex.Exposure

  defmodule TestKey do
    use Entitiex.Entity

    format_keys :to_s

    expose :without_alias
    expose :with_alias, as: :alias_of_key
    expose :with_format, format_key: :lcamelize
    expose :with_format_and_alias, as: :formatted_alias_of_key, format_key: :lcamelize
  end

  defmodule TestValue do
    use Entitiex.Entity

    format_with :reverse, &String.reverse/1

    expose :without_alias
    expose :with_alias, as: :alias_of_key
    expose :with_format, format_key: :lcamelize
    expose :with_format_and_alias, as: :formatted_alias_of_key, format_key: :lcamelize
  end

  setup %{entity: entity, attribute: attribute} do
    exposure = Enum.find(entity.exposures(), &(&1.attribute == attribute))
    {:ok, exposure: exposure}
  end

  describe "key" do
    @tag entity: TestKey, attribute: :without_alias
    test "without alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "without_alias")
    end

    @tag entity: TestKey, attribute: :with_alias
    test "with alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "alias_of_key")
    end

    @tag entity: TestKey, attribute: :with_format
    test "with format", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "withFormat")
    end

    @tag entity: TestKey, attribute: :with_format_and_alias
    test "with format and alias", %{exposure: exposure} do
      assert(Exposure.key(exposure) == "formattedAliasOfKey")
    end
  end
end
