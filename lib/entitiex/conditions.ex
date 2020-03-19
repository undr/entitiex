defmodule Entitiex.Conditions do
  alias Entitiex.Types

  @spec compile(module(), Types.exp_opts()) :: Types.normal_funcs()
  def compile(entity, opts) do
    [expose_nil_func(opts)|get_conditions(entity, opts)]
    |> Enum.reject(&is_nil/1)
  end

  @spec run(Types.normal_funcs(), map(), any(), map()) :: boolean()
  def run(conditions, struct, value, context \\ %{})
  def run([], _struct, _value, _context), do: true
  def run(conditions, struct, value, context) when is_list(conditions) do
    Enum.reduce(conditions, true, fn (condition, acc) ->
      case Function.info(condition, :arity) do
        {:arity, 2} ->
          acc && condition.(struct, value)
        {:arity, 3} ->
          acc && condition.(struct, value, context)
        _ ->
          throw {:error, {:wrong_condition, condition}}
      end
    end)
  end

  @spec expose_nil?(map(), any()) :: boolean()
  def expose_nil?(_struct, value),
    do: !is_nil(value)

  defp get_conditions(entity, opts) do
    with {:ok, conditions} <- Keyword.fetch(opts, :if) do
      Entitiex.Normalizer.normalize(:condition, conditions, entity)
    else
      :error -> []
    end
  end

  defp expose_nil_func(opts) do
    if Keyword.get(opts, :expose_nil, true), do: nil, else: &Entitiex.Conditions.expose_nil?/2
  end
end
