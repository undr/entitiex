defmodule Entitiex.Exposure.EntityHandler do
  use Entitiex.Exposure.Handler

  alias Entitiex.Exposure
  alias Entitiex.Types

  @spec value(Types.exposure(), any()) :: any()
  def value(%Exposure{opts: opts}, value) do
    with {:ok, nested} <- Keyword.fetch(opts, :nested) do
      apply_nested(nested, value)
    else
      _ -> nil
    end
  end

  @spec setup(Types.exp_opts()) :: {Types.handler(), Types.exp_opts()} | nil
  def setup(opts) do
    merge = Keyword.get(opts, :merge, false)

    case Keyword.fetch(opts, :using) do
      {:ok, entity} -> {__MODULE__, [nested: entity, merge: merge]}
      :error -> nil
    end
  end

  defp apply_nested(nested, value),
    do: apply(nested, :serializable_map, [value])
end
