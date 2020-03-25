defmodule Entitiex do
  @moduledoc "README.md" |> File.read!() |> String.split("<!-- EXDOC -->") |> Enum.fetch!(1)

  @doc """
  It contains named formatters. It's possible to access them using the name.
  Available formatters are: `:to_s`, `:to_atom`, `:upcase`, `:downcase`,
  `:camelize`, `:lcamelize`.

      iex> Entitiex.default_formatters() |> Keyword.fetch(:downcase)
      {:ok, &Entitiex.Formatter.downcase/1}
  """
  @spec default_formatters() :: [{atom(), fun()}]
  def default_formatters do
    [
      to_s: &Entitiex.Formatter.to_s/1,
      to_atom: &Entitiex.Formatter.to_atom/1,
      upcase: &Entitiex.Formatter.upcase/1,
      downcase: &Entitiex.Formatter.downcase/1,
      camelize: &Entitiex.Formatter.camelize/1,
      lcamelize: &Entitiex.Formatter.lcamelize/1
    ]
  end
end
