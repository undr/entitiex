defmodule Entitiex.Utils do
  @type opts :: [{:deep, boolean()}]

  @spec transform_keys(Entitiex.Types.extra() | [Entitiex.Types.extra()], fun(), opts()) :: map()
  def transform_keys(enum, func, opts \\ [])
  def transform_keys([{key, _}|_] = keyword, func, opts) when is_atom(key),
    do: do_transform_keys(keyword, func, opts)
  def transform_keys(map, func, opts) when is_map(map),
    do: do_transform_keys(map, func, opts)
  def transform_keys(list, func, opts) when is_list(list),
    do: Enum.map(list, &(transform_keys(&1, func, opts)))
  def transform_keys(value, _func, _opts),
    do: value

  defp do_transform_keys(map, func, opts) do
    deep = Keyword.get(opts, :deep, true)

    Enum.map(map, fn
      {key, [{k, _}|_] = value} when is_atom(k) ->
        value = if deep, do: transform_keys(value, func, opts), else: Enum.into(value, %{})
        {func.(key), value}

      {key, value} when is_map(value) or is_list(value) ->
        value = if deep, do: transform_keys(value, func, opts)
        {func.(key), value}

      {key, value} ->
        {func.(key), value}
    end) |> Enum.into(%{})
  end

  @spec func_exists?(module() | nil, atom(), arity()) :: boolean()
  def func_exists?(nil, _func, _arity),
    do: false
  def func_exists?(module, func, arity),
    do: func_exported?(module, func, arity) || func_defined?(module, func, arity)

  defp func_exported?(module, func, arity),
    do: Kernel.function_exported?(module, func, arity)

  defp func_defined?(module, func, arity),
    do: Module.open?(module) && Module.defines?(module, {func, arity}, :def)
end
