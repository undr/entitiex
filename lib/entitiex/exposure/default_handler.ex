defmodule Entitiex.Exposure.DefaultHandler do
  use Entitiex.Exposure.Handler

  alias Entitiex.Exposure
  alias Entitiex.Utils

  def value(%Exposure{entity: entity, attribute: attribute, key: key}, %{__struct__: module} = struct),
    do: get_value(struct, attribute, key, entity, module)
  def value(%Exposure{entity: entity, attribute: attribute, key: key}, struct),
    do: get_value(struct, attribute, key, entity, nil)

  defp get_value(struct, attribute, key, entity, module) do
    cond do
      Utils.func_exists?(module, attribute, 1) ->
        apply(module, attribute, [struct])

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
