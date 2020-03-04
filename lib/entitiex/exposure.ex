defmodule Entitiex.Exposure do
  alias Entitiex.Exposure.EntityHandler
  alias Entitiex.Exposure.FormattedHandler
  alias Entitiex.Exposure.DefaultHandler
  alias Entitiex.Types

  @handlers [DefaultHandler, EntityHandler, FormattedHandler]

  defstruct [key: nil, attribute: nil, conditions: nil, entity: nil, handlers: [], opts: []]

  @type t :: Types.exposure()

  @spec key(t()) :: any()
  def key(%{handlers: handlers} = exposure) do
    Enum.reduce(handlers, exposure.key, fn(handler, acc) ->
      handler.key(exposure, acc)
    end)
  end

  @spec value(t(), map()) :: Types.value_tuple()
  def value(%{handlers: handlers, opts: opts} = exposure, struct) do
    value = get_value(struct, handlers, exposure)
    merge = Keyword.get(opts, :merge, false) && is_map(value)
    expose = expose?(exposure, struct, value)

    cond do
      expose && merge -> {:merge, value}
      expose -> {:put, value}
      true -> :skip
    end
  end

  @spec handlers(Types.exp_opts()) :: {Types.handlers(), Types.exp_opts()}
  def handlers(opts) do
    data = @handlers
    |> Enum.map(fn handler -> handler.setup(opts) end)
    |> Enum.reject(&is_nil/1)

    {Keyword.keys(data), Keyword.values(data) |> Enum.reduce(&Keyword.merge/2)}
  end

  @spec expose?(t(), map(), any()) :: boolean()
  def expose?(%{conditions: conditions}, struct, value),
    do: Entitiex.Conditions.run(conditions, struct, value)

  defp get_value(value, [], _exposure),
    do: value
  defp get_value(nil, _handlers, _exposure),
    do: nil
  defp get_value(value, [handler|handlers], exposure),
    do: handler.value(exposure, value) |> get_value(handlers, exposure)
end
