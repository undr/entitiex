defmodule Entitiex.Options do
  alias Entitiex.Types

  @merge [:format, :format_key, :if]

  @spec merge(Types.exp_opts(), Types.exp_opts()) :: Types.exp_opts()
  def merge(opts1, opts2),
    do: Keyword.merge(opts1, opts2, &(merge_option(&1, &2, &3)))

  defp merge_option(key, first, second) when key in @merge do
    cond do
      is_list(first) and is_list(second) -> first ++ second
      !is_list(first) and is_list(second) -> [first|second]
      is_list(first) and !is_list(second) -> first ++ [second]
      true -> [first, second]
    end
  end
  defp merge_option(_key, _first, second),
    do: second
end
