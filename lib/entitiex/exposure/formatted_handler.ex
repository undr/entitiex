defmodule Entitiex.Exposure.FormatterHandler do
  use Entitiex.Exposure.Handler

  def value(%{opts: opts, entity: entity} = exposure, struct) do
    with {:ok, func} <- Keyword.fetch(opts, :format_with),
         {:ok, func} <- normalize_formatter(func, entity),
         value       <- extract_value(exposure, struct) do
      if expose?(exposure, struct, value), do: {:ok, func.(value)}, else: :skip
    end
  end

  defp normalize_formatter(func, _entity) when is_function(func),
    do: {:ok, func}
  defp normalize_formatter(name, entity) when is_atom(name),
    do: {:ok, Keyword.get(entity.formatters(), name)}
end
