defmodule Entitiex do
  def default_formatters do
    [
      to_s: &Entitiex.Exposure.Formatter.to_s/1,
      to_atom: &Entitiex.Exposure.Formatter.to_atom/1,
      upcase: &Entitiex.Exposure.Formatter.upcase/1,
      downcase: &Entitiex.Exposure.Formatter.downcase/1,
      camelize: &Entitiex.Exposure.Formatter.camelize/1,
      lcamelize: &Entitiex.Exposure.Formatter.lcamelize/1
    ]
  end
end
