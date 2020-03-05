defmodule Entitiex do
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
