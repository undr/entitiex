defmodule Entitiex.OptionsTest do
  use ExUnit.Case

  alias Entitiex.Options

  test "test" do
    assert(Options.merge([key1: :value2, key2: :value2], [key1: :value]) == [key2: :value2, key1: :value])
    assert(Options.merge([format: :format1, key: :value], [format: :format2, key: :value2]) == [format: [:format1, :format2], key: :value2])
    assert(Options.merge([format: [:format1], key: :value], [format: :format2, key: :value2]) == [format: [:format1, :format2], key: :value2])
    assert(Options.merge([format: :format1, key: :value], [format: [:format2], key: :value2]) == [format: [:format1, :format2], key: :value2])
    assert(Options.merge([format: [:format1], key: :value], [format: [:format2], key: :value2]) == [format: [:format1, :format2], key: :value2])
  end
end
