defmodule Entitiex.Exposure do
  alias Entitiex.Exposure.EntityHandler
  alias Entitiex.Exposure.FormatterHandler
  alias Entitiex.Exposure.DefaultHandler

  defstruct [key: nil, attribute: nil, conditions: nil, entity: nil, handler: DefaultExposure, opts: []]

  def key(%{handler: handler} = exposure) do
    handler.key(exposure)
  end

  def value(%{handler: handler} = exposure, struct) do
    handler.value(exposure, struct)
  end

  def handler(opts) do
    entity = Keyword.get(opts, :using)
    format = Keyword.get(opts, :format_with)

    cond do
      entity -> {EntityHandler, [nested: entity]}
      format -> {FormatterHandler, [format_with: format]}
      true   -> {DefaultHandler, []}
    end
  end
end
