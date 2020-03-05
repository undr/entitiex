defmodule Entitiex.Exposure.FormattedHandlerTest do
  use ExUnit.Case

  alias Entitiex.Exposure.FormattedHandler

  defmodule Test do
    use Entitiex.Entity

    def reverse(value) do
      to_string(value) |> String.reverse
    end
  end

  describe "value" do
    test "when format is not defined" do
      exposure = %Entitiex.Exposure{opts: [], entity: Test}
      assert(FormattedHandler.value(exposure, 1) == 1)
      assert(FormattedHandler.value(exposure, :atom) == :atom)
      assert(FormattedHandler.value(exposure, "string") == "string")
      assert(FormattedHandler.value(exposure, [1, :atom, "string"]) == [1, :atom, "string"])
    end

    test "when format is defined as list" do
      exposure = %Entitiex.Exposure{opts: [format: [&Entitiex.Formatter.to_s/1, &String.reverse/1]], entity: Test}
      assert(FormattedHandler.value(exposure, 1) == "1")
      assert(FormattedHandler.value(exposure, :atom) == "mota")
      assert(FormattedHandler.value(exposure, "string") == "gnirts")
    end
  end

  describe "key" do
    test "when format is not defined" do
      exposure = %Entitiex.Exposure{opts: [], entity: Test}
      assert(FormattedHandler.key(exposure, :entity_key) == :entity_key)
    end

    test "when format is defined as list" do
      exposure = %Entitiex.Exposure{opts: [format_key: [&Entitiex.Formatter.to_s/1, &String.reverse/1]], entity: Test}
      assert(FormattedHandler.key(exposure, :entity_key) == "yek_ytitne")
    end
  end

  test "setup" do
    assert(FormattedHandler.setup(Test, []) == nil)
    assert(FormattedHandler.setup(Test, [format: :reverse]) == {FormattedHandler, [format: [&Test.reverse/1]]})
    assert(FormattedHandler.setup(Test, [format_key: :reverse]) == {FormattedHandler, [format_key: [&Test.reverse/1]]})
    assert(
      FormattedHandler.setup(Test, [format_key: :reverse, format: :reverse]) ==
        {FormattedHandler, [format_key: [&Test.reverse/1], format: [&Test.reverse/1]]}
    )

    assert(
      FormattedHandler.setup(Test, [format_key: :reverse, format: :reverse, using: 'using']) ==
        {FormattedHandler, [format_key: [&Test.reverse/1], format: [&Test.reverse/1]]}
    )
  end
end
