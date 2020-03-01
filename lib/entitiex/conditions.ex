defmodule Entitiex.Conditions do
  def compile(opts) do
    [expose_nil_func(opts), get_condiion(opts)]
    |> Enum.reject(&is_nil/1)
  end

  def run([], _struct, _value), do: true
  def run(conditions, struct, value) when is_list(conditions) do
    Enum.reduce(conditions, true, fn (condition, acc) ->
      acc && execute(condition, struct, value)
    end)
  end

  def expose_nil?(_struct, value),
    do: !is_nil(value)

  defp get_condiion(opts),
    do: normalize_condition(Keyword.get(opts, :if), Keyword.get(opts, :entity))

  defp normalize_condition(func, nil) when is_function(func),
    do: func
  defp normalize_condition(func, entity) when is_function(func),
    do: {entity, func}
  defp normalize_condition({m, f}, nil) when is_atom(m) and is_atom(f),
    do: {m, f, []}
  defp normalize_condition({m, f, a}, nil) when is_atom(m) and is_atom(f) and is_list(a),
    do: {m, f, a}
  defp normalize_condition(_func, _entity),
    do: nil

  defp expose_nil_func(opts) do
    case Keyword.get(opts, :expose_nil, false) do
      false -> &Entitiex.Conditions.expose_nil?/2
      _     -> nil
    end
  end

  defp execute(func, struct, value) when is_function(func),
    do: func.(struct, value)
  defp execute({mod, func, args}, struct, value),
    do: apply(mod, func, [struct, value] ++ args)
end
