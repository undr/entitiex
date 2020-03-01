defmodule Entitiex.Exposure.EntityHandler do
  use Entitiex.Exposure.Handler

  def value(%{opts: opts} = exposure, struct) do
    with {:ok, nested} <- Keyword.fetch(opts, :nested),
         value         <- extract_value(exposure, struct),
         expose        <- expose?(exposure, struct, value) do
      apply_nested(nested, value, expose)
    end
  end

  defp apply_nested(_nested, _value, true),
    do: :skip
  defp apply_nested(nested, value, false),
    do: {:ok, apply(nested, :serializable_map, [value])}
end
