defmodule Entitiex.Exposure.EntityHandler do
  use Entitiex.Exposure.Handler

  def value(%Entitiex.Exposure{opts: opts}, value) do
    with {:ok, nested} <- Keyword.fetch(opts, :nested) do
      apply_nested(nested, value)
    else
      _ -> nil
    end
  end

  def setup(opts) do
    case Keyword.fetch(opts, :using) do
      {:ok, entity} -> {__MODULE__, [nested: entity]}
      :error -> nil
    end
  end

  defp apply_nested(nested, value),
    do: apply(nested, :serializable_map, [value])
end
