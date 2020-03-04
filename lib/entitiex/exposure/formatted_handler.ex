defmodule Entitiex.Exposure.FormattedHandler do
  use Entitiex.Exposure.Handler

  alias Entitiex.Exposure.Formatter
  alias Entitiex.Exposure
  alias Entitiex.Types

  @options [:format, :format_key]

  @spec value(Types.exposure(), any()) :: any()
  def value(%Exposure{opts: opts, entity: entity}, value) do
    format(entity, value, opts, :format)
  end

  @spec key(Types.exposure(), any()) :: any()
  def key(%Exposure{opts: opts, entity: entity}, key) do
    format(entity, key, opts, :format_key)
  end

  @spec setup(Types.exp_opts()) :: {Types.handler(), Types.exp_opts()} | nil
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
