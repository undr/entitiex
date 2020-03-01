defmodule Entitiex.Exposure.DefaultHandler do
  use Entitiex.Exposure.Handler

  def value(exposure, struct) do
    value = extract_value(exposure, struct)
    if expose?(exposure, struct, value), do: {:ok, value}, else: :skip
  end
end
