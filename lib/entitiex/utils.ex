defmodule Entitiex.Utils do
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
end
