defmodule Entitiex.Exposure.DefaultHandler do
  use Entitiex.Exposure.Handler

  def value(%Entitiex.Exposure{entity: entity, attribute: attribute}, struct) do
    if defined?(entity, attribute) do
      apply(entity, attribute, [struct])
    else
      Map.get(struct, attribute)
    end
  end

  def key(%Entitiex.Exposure{entity: entity}, key) do
    entity.format_key(key)
  end

  defp defined?(entity, attribute) do
    fun_exported?(entity, attribute) || fun_defined?(entity, attribute)
  end

  defp fun_exported?(entity, attribute),
    do: Kernel.function_exported?(entity, attribute, 1)

  defp fun_defined?(entity, attribute),
    do: Module.open?(entity) && Module.defines?(entity, {attribute, 1}, :def)
end
