defmodule Entitiex.Exposure do
  @moduledoc false

  alias Entitiex.Exposure.EntityHandler
  alias Entitiex.Exposure.FormattedHandler
  alias Entitiex.Exposure.DefaultHandler
  alias Entitiex.Types

  @handlers [DefaultHandler, EntityHandler, FormattedHandler]

  defstruct [key: nil, attribute: nil, conditions: nil, entity: nil, handlers: [], opts: []]

  @type t :: Types.exposure()

  @spec new(module(), Types.attr(), Types.exp_opts()) :: t()
  def new(entity, attribute, opts) do
    key = Keyword.get(opts, :as, attribute)
    conditions = Entitiex.Conditions.compile(entity, opts)
    {handlers, opts} = setup_handlers(entity, opts)

    %Entitiex.Exposure{
      conditions: conditions,
      attribute: attribute,
      handlers: handlers,
      entity: entity,
      opts: opts,
      key: key
    }
  end

  @spec key(t()) :: any()
  def key(%{handlers: handlers} = exposure) do
    Enum.reduce(handlers, exposure.key, fn(handler, acc) ->
      handler.key(exposure, acc)
    end)
  end

  @spec value(t(), map(), map()) :: Types.value_tuple()
  def value(%{handlers: handlers, opts: opts} = exposure, struct, context \\ %{}) do
    value = get_value(struct, handlers, exposure, context)
    merge = Keyword.get(opts, :merge, false) && is_map(value)
    expose = expose?(exposure, struct, value, context)

    cond do
      expose && merge -> {:merge, value}
      expose -> {:put, value}
      true -> :skip
    end
  end

  @spec setup_handlers(module(), Types.exp_opts()) :: {Types.handlers(), Types.normal_exp_opts()}
  def setup_handlers(entity, opts) do
    data = @handlers
    |> Enum.map(fn handler -> handler.setup(entity, opts) end)
    |> Enum.reject(&is_nil/1)

    {Keyword.keys(data), Keyword.values(data) |> Enum.reduce(&Keyword.merge/2)}
  end

  @spec expose?(t(), map(), any(), map()) :: boolean()
  def expose?(%{conditions: conditions}, struct, value, context),
    do: Entitiex.Conditions.run(conditions, struct, value, context)

  defp get_value(value, [], _exposure, _context),
    do: value
  defp get_value(nil, _handlers, _exposure, _context),
    do: nil
  defp get_value(value, [handler|handlers], exposure, context),
    do: handler.value(exposure, value, context) |> get_value(handlers, exposure, context)
end
