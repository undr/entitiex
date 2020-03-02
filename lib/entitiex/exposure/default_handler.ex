defmodule Entitiex.Exposure.DefaultHandler do
  use Entitiex.Exposure.Handler

  alias Entitiex.Exposure
  alias Entitiex.Utils

  def value(%Exposure{attribute: attribute}, %{__struct__: module} = struct) do
    cond do
      Utils.func_exists?(module, attribute, 1) -> apply(module, attribute, [struct])
      true -> Map.get(struct, attribute)
    end
  end
  def value(%Exposure{entity: entity, attribute: attribute, key: key}, struct) do
    cond do
      Utils.func_exists?(entity, attribute, 1) ->
        apply(entity, attribute, [struct])

      Utils.func_exists?(entity, attribute, 2) ->
        apply(entity, attribute, [struct, key])

      true ->
        Map.get(struct, attribute)
    end
  end

  def key(%Exposure{entity: entity}, key) do
    entity.format_key(key)
  end
end
