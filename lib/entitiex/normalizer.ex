defmodule Entitiex.Normalizer do
  @moduledoc false

  alias Entitiex.Utils
  alias Entitiex.Types

  @type type :: :formatter | :condition

  @spec normalize(type(), Types.funcs(), module()) :: Types.normal_funcs()
  def normalize(type, funcs, resolver) when is_list(funcs),
    do: normalize(type, funcs, resolver, []) |> Enum.reverse()
  def normalize(type, func, resolver),
    do: normalize(type, [func], resolver)

  @spec normalize(type(), Types.funcs(), module(), Types.normal_funcs()) :: Types.normal_funcs()
  def normalize(_type, [], _resolver, result),
    do: result
  def normalize(type, [func|funcs], resolver, result) when is_function(func),
    do: normalize(type, funcs, resolver, [func|result])
  def normalize(type, [func|funcs], resolver, result) when is_atom(func) do
    func = normalize_type(type, func, resolver)
    normalize(type, funcs, resolver, [func|result])
  end

  defp normalize_type(:formatter, formatter, resolver) do
    case Keyword.fetch(Entitiex.default_formatters(), formatter) do
      {:ok, formatter} ->
        formatter

      :error ->
        unless Utils.func_exists?(resolver, formatter, 1) do
          raise "Formatter function is not found (:#{formatter} or #{inspect(resolver)}.#{formatter}/1)"
        end

        Function.capture(resolver, formatter, 1)
    end
  end

  defp normalize_type(:condition, condition, resolver) do
    cond do
      Utils.func_exists?(resolver, condition, 2) ->
        Function.capture(resolver, condition, 2)

      Utils.func_exists?(resolver, condition, 3) ->
        Function.capture(resolver, condition, 3)

      true ->
        raise "Condition function is not found (#{inspect(resolver)}.#{condition}/2 or #{inspect(resolver)}.#{condition}/3)"
    end
  end
end
