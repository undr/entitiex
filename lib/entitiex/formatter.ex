defmodule Entitiex.Formatter do
  alias Entitiex.Types

  @spec to_s(any() | [any()]) :: String.t()
  def to_s(value) when is_list(value),
    do: Enum.map(value, &to_s/1)
  def to_s(value),
    do: to_string(value)

  @spec to_atom(any() | [any()]) :: atom()
  def to_atom(value) when is_list(value),
    do: Enum.map(value, &to_atom/1)
  def to_atom(value),
    do: to_string(value) |> String.to_atom

  @spec camelize(any() | [any()]) :: String.t()
  def camelize(value) when is_list(value),
    do: Enum.map(value, &camelize/1)
  def camelize(value) when is_atom(value),
    do: to_string(value) |> camelize
  def camelize(value),
    do: Macro.camelize(value)

  @spec lcamelize(any() | [any()]) :: String.t()
  def lcamelize(value) when is_list(value),
    do: Enum.map(value, &lcamelize/1)
  def lcamelize(value) when is_atom(value),
    do: to_string(value) |> lcamelize
  def lcamelize(value) do
    camelized = Macro.camelize(value)
    first = String.first(camelized)
    String.replace_prefix(camelized, first, String.downcase(first))
  end

  @spec upcase(any() | [any()]) :: String.t
  def upcase(value) when is_list(value),
    do: Enum.map(value, &upcase/1)
  def upcase(value),
    do: to_string(value) |> String.upcase

  @spec downcase(any() | [any()]) :: String.t
  def downcase(value) when is_list(value),
    do: Enum.map(value, &downcase/1)
  def downcase(value),
    do: to_string(value) |> String.downcase

  @spec format(Types.normal_funcs(), any()) :: {:ok, any()} | :error
  def format(formatter, value) when is_function(formatter),
    do: format([formatter], value)
  def format(formatters, value) do
    formatters
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(value, fn func, acc -> func.(acc) end)
  end

  @spec normalize(Types.funcs(), module()) :: Types.normal_funcs()
  def normalize(formatters, entity),
    do: Entitiex.Normalizer.normalize(:formatter, formatters, entity)
end
