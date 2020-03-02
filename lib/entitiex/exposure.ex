defmodule Entitiex.Exposure do
  alias Entitiex.Exposure.EntityHandler
  alias Entitiex.Exposure.FormattedHandler
  alias Entitiex.Exposure.DefaultHandler

  @handlers [DefaultHandler, EntityHandler, FormattedHandler]

  defstruct [key: nil, attribute: nil, conditions: nil, entity: nil, handlers: [], opts: []]

  def key(%{handlers: handlers} = exposure) do
    Enum.reduce(handlers, exposure.key, fn(handler, acc) ->
      handler.key(exposure, acc)
    end)
  end

  def value(%{handlers: handlers} = exposure, struct) do
    value = get_value(struct, handlers, exposure)

    if expose?(exposure, struct, value), do: {:ok, value}, else: :skip
  end

  defp get_value(value, [], _exposure),
    do: value
  defp get_value(nil, _handlers, _exposure),
    do: nil
  defp get_value(value, [handler|handlers], exposure) do
    handler.value(exposure, value) |> get_value(handlers, exposure)
  end

  def handlers(opts) do
    data = @handlers
    |> Enum.map(fn handler -> handler.setup(opts) end)
    |> Enum.reject(&is_nil/1)

    {Keyword.keys(data), Keyword.values(data) |> Enum.reduce(&Keyword.merge/2)}
  end

  def expose?(%{conditions: conditions}, struct, value),
    do: Entitiex.Conditions.run(conditions, struct, value)
end
