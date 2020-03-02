defmodule Entitiex.Exposure.FormattedHandler do
  use Entitiex.Exposure.Handler

  alias Entitiex.Exposure.Formatter

  @options [:format_with, :format_key]

  def value(%Entitiex.Exposure{opts: opts, entity: entity}, value) do
    format(entity, value, opts, :format_with)
  end

  def key(%Entitiex.Exposure{opts: opts, entity: entity}, key) do
    format(entity, key, opts, :format_key)
  end

  def setup(opts) do
    case Keyword.take(opts, @options) do
      []   -> nil
      opts -> {__MODULE__, opts}
    end
  end

  defp format(entity, value, opts, name) do
    with {:ok, func} <- Keyword.fetch(opts, name),
         {:ok, value} <- Formatter.format(entity, func, value) do
      value
    else
      _ -> value
    end
  end
end
