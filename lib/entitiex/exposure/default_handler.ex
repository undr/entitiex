defmodule Entitiex.Exposure.DefaultHandler do
  @moduledoc false

  use Entitiex.Exposure.Handler

  alias Entitiex.Exposure
  alias Entitiex.Utils
  alias Entitiex.Types

  @spec value(Types.exposure(), any(), map()) :: any()
  def value(exposure, struct, context \\ %{})
  def value(%Exposure{attribute: nil}, struct, _context),
    do: struct
  def value(%Exposure{entity: entity, attribute: attribute, key: key}, %{__struct__: module} = struct, context),
    do: get_value(struct, attribute, key, entity, context, module)
  def value(%Exposure{entity: entity, attribute: attribute, key: key}, struct, context),
    do: get_value(struct, attribute, key, entity, context, nil)

  defp get_value(struct, attribute, key, entity, context, module) do
    cond do
      Utils.func_exists?(entity, attribute, 1) ->
        apply(entity, attribute, [struct])

      Utils.func_exists?(entity, attribute, 2) ->
        apply(entity, attribute, [struct, key])

      Utils.func_exists?(entity, attribute, 3) ->
        apply(entity, attribute, [struct, key, context])

      Utils.func_exists?(module, attribute, 1) ->
        apply(module, attribute, [struct])

      true ->
        Map.get(struct, attribute)
    end
  end

  @spec key(Types.exposure(), any()) :: any()
  def key(%Exposure{entity: entity}, key) do
    entity.format_key(key)
  end

  @spec setup(module(), Types.exp_opts()) :: {Types.handler(), Types.normal_exp_opts()}
  def setup(_entity, opts) do
    merge = Keyword.get(opts, :merge, false)
    {__MODULE__, [merge: merge]}
  end
end
