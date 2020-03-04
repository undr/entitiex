defmodule Entitiex.Utils do
  @type opts :: [{:deep, boolean()}]

  @spec transform_keys(Entitiex.Types.extra(), fun(), opts()) :: map()
  def transform_keys(map, func, opts \\ []) do
    deep = Keyword.get(opts, :deep, true)

    Enum.map(map, fn
      {key, value} when is_map(value) or is_list(value) ->
        value = if deep, do: transform_keys(value, func, opts), else: Enum.into(value, %{})
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
