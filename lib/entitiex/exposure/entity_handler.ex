defmodule Entitiex.Exposure.EntityHandler do
  use Entitiex.Exposure.Handler

  alias Entitiex.Exposure
  alias Entitiex.Types

  @spec value(Types.exposure(), any(), map()) :: any()
  def value(%Exposure{opts: opts}, value, context \\ %{}) do
    with {:ok, nested} <- Keyword.fetch(opts, :using) do
      apply_nested(nested, value, context)
    else
      _ -> nil
    end
  end

  @spec setup(module(), Types.exp_opts()) :: {Types.handler(), Types.normal_exp_opts()} | nil
  def setup(_entity, opts) do
    case Keyword.fetch(opts, :using) do
      {:ok, entity} -> {__MODULE__, [using: entity]}
      :error -> nil
    end
  end

  defp apply_nested(nested, value, context),
    do: apply(nested, :serializable_map, [value, context])
end
