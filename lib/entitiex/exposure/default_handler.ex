defmodule Entitiex.Exposure.DefaultHandler do
  use Entitiex.Exposure.Handler

  def value(%Entitiex.Exposure{entity: entity, attribute: attribute}, struct) do
    if function_exported?(entity, attribute, 1) do
      apply(entity, attribute, [struct])
    else
      Map.get(struct, attribute)
    end
  end

  def key(%Entitiex.Exposure{entity: entity}, key) do
    entity.format_key(key)
  end
end
