defmodule Entitiex.Exposure.Formatter do
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

  @spec format(module(), Types.formatter(), any()) :: any()
  def format(entity, func, value) do
    with {:ok, func} <- normalize_formatter(func, entity) do
      {:ok, func.(value)}
    end
  end

  defp normalize_formatter(func, _entity) when is_function(func),
    do: {:ok, func}
  defp normalize_formatter(name, entity) when is_atom(name),
    do: Keyword.fetch(formatters(entity), name)

  defp formatters(entity) do
    Keyword.merge(Entitiex.default_formatters(), entity.formatters())
  end
end
