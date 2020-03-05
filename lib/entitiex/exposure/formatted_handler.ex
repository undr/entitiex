defmodule Entitiex.Exposure.FormattedHandler do
  use Entitiex.Exposure.Handler

  alias Entitiex.Formatter
  alias Entitiex.Exposure
  alias Entitiex.Types

  @options [:format, :format_key]

  @spec value(Types.exposure(), any()) :: any()
  def value(%Exposure{opts: opts}, value) do
    format(value, opts, :format)
  end

  @spec key(Types.exposure(), any()) :: any()
  def key(%Exposure{opts: opts}, key) do
    format(key, opts, :format_key)
  end

  @spec setup(module(), Types.exp_opts()) :: {Types.handler(), Types.normal_exp_opts()} | nil
  def setup(entity, opts) do
    case Keyword.take(opts, @options) do
      []   -> nil
      opts -> {__MODULE__, normalize_options(entity, opts)}
    end
  end

  defp normalize_options(entity, opts) do
    Enum.map(opts, fn {key, formatters} -> {key, Formatter.normalize(formatters, entity)} end)
  end

  defp format(value, opts, name) do
    with {:ok, formatters} <- Keyword.fetch(opts, name)do
      Formatter.format(formatters, value)
    else
      _ -> value
    end
  end
end
