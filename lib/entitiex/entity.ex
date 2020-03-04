defmodule Entitiex.Entity do
  alias Entitiex.Exposure

  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      @__exposures__ []
      @__formatters__ []
      @__key_formatters__ []
      @__root__ [singular: nil, plural: nil]

      Module.register_attribute(__MODULE__, :__exposures__, accumulate: true)
      Module.register_attribute(__MODULE__, :__formatters__, accumulate: true)
      Module.register_attribute(__MODULE__, :__key_formatters__, accumulate: true)

      alias Entitiex.Exposure
      alias Entitiex.Utils

      import unquote(__MODULE__), only: [
        expose: 2, expose: 1, root: 2, root: 1, format_with: 2, format_keys: 1,
        nesting: 2, nesting: 3, inline: 2, inline: 3
      ]

      @before_compile unquote(__MODULE__)

      def represent(struct, opts \\ [])
      def represent(structs, opts) when is_list(structs) do
        context = Keyword.get(opts, :context, %{})
        extra = Keyword.get(opts, :extra, %{})
        root = get_root(opts, :plural)

        do_represent(structs, root, context, extra)
      end
      def represent(struct, opts) do
        context = Keyword.get(opts, :context, %{})
        extra = Keyword.get(opts, :extra, %{})
        root = get_root(opts, :singular)

        do_represent(struct, root, context, extra)
      end

      defp do_represent(struct, :nil, _context, extra),
        do: serializable_map(struct)
      defp do_represent(struct, root, _context, extra) do
        extra
        |> Utils.transform_keys(&(format_key(&1)))
        |> Map.put(format_key(root), serializable_map(struct))
      end

      def serializable_map(structs) when is_list(structs),
        do: Enum.map(structs, fn (struct) -> serializable_map(struct) end)
      def serializable_map(struct) when is_map(struct) do
        Enum.reduce(exposures(), %{}, fn (exposure, acc) ->
          with key <- Exposure.key(exposure) do
            case Exposure.value(exposure, struct) do
              {:merge, value} -> Map.merge(acc, value)
              {:put, value} -> Map.put(acc, key, value)
              :skip -> acc
            end
          end
        end)
      end
      def serializable_map(struct),
        do: struct

      defoverridable [serializable_map: 1]
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      def formatters do
        @__formatters__
      end

      def key_formatters do
        @__key_formatters__
      end

      def exposures do
        @__exposures__
      end

      def format_key(key) do
        key_formatters()
        |> Enum.reverse()
        |> Enum.reduce(key, fn func, acc ->
          case Entitiex.Exposure.Formatter.format(__MODULE__, func, acc) do
            {:ok, value} -> value
            _ -> acc
          end
        end)
      end

      def get_root(opts, type) do
        case Keyword.get(opts, :root) do
          nil -> Keyword.get(@__root__, type)
          any -> any
        end
      end
    end
  end

  defmacro expose(attributes, opts \\ []),
    do: expose_attributes(attributes, opts)

  defmacro nesting(key, [do: block]),
    do: expose_attributes([nil], [nesting: true, as: key], block)
  defmacro nesting(key, opts, [do: block]),
    do: expose_attributes([nil], Keyword.merge(opts, [nesting: true, as: key]), block)

  defmacro inline(attribute, [do: block]),
    do: expose_attributes([attribute], [nesting: true], block)
  defmacro inline(attribute, opts, [do: block]),
    do: expose_attributes([attribute], Keyword.merge(opts, [nesting: true]), block)

  defp expose_attributes(attribute, opts, block \\ nil)
  defp expose_attributes(attribute, opts, block) when is_binary(attribute) or is_atom(attribute),
    do: expose_attributes([attribute], opts, block)
  defp expose_attributes(attributes, opts, block) when is_list(attributes) do
    Enum.map(attributes, fn (attribute) ->
      key = Keyword.get(opts, :as, attribute)
      nesting = Keyword.get(opts, :nesting, false)
      conditions = Entitiex.Conditions.compile(opts)

      quote do
        opts = if unquote(nesting) do
          using = Entitiex.Entity.generate_module(
            __ENV__.module,
            unquote(Macro.escape(block)),
            Macro.Env.location(__ENV__)
          )
          Keyword.merge(unquote(opts), [using: using])
        else
          unquote(opts)
        end

        {handlers, opts} = Entitiex.Exposure.handlers(opts)

        @__exposures__ %Entitiex.Exposure{
          conditions: unquote(Macro.escape(conditions)),
          attribute: unquote(attribute),
          handlers: handlers,
          entity: __ENV__.module,
          opts: opts,
          key: unquote(key)
        }
      end
    end)
  end

  defmacro root(plural, singular \\ nil),
    do: set_root(plural, singular)

  defp set_root(plural, nil),
    do: set_root(plural, plural)
  defp set_root(plural, singular) do
    quote location: :keep do
      @__root__ [singular: unquote(singular), plural: unquote(plural)]
    end
  end

  defmacro format_keys(func) do
    quote location: :keep do
      @__key_formatters__ unquote(func)
    end
  end

  defmacro format_with(name, func) do
    quote location: :keep do
      @__formatters__ {unquote(name), unquote(func)}
    end
  end

  @spec generate_module(module(), any(), any()) :: module()
  def generate_module(base, content, env) do
    index = base
    |> exposures()
    |> length()

    key_formatters = base
    |> key_formatters()
    |> Enum.map(fn key -> quote(do: @__key_formatters__ unquote(key)) end)

    formatters = base
    |> formatters()
    |> Enum.map(fn key -> quote(do: @__formatters__ unquote(key)) end)

    content = content
    |> inject_code(key_formatters)
    |> inject_code(formatters)
    |> inject_code(quote do: use Entitiex.Entity)

    {:module, nesting, _, _} = Module.create(:"#{base}.CodeGen.Nesting#{index}", content, env)
    nesting
  end

  defp exposures(base) do
    if Module.open?(base) do
      Module.get_attribute(base, :__exposures__)
    else
      base.exposures()
    end
  end

  defp formatters(base) do
    if Module.open?(base) do
      Module.get_attribute(base, :__formatters__)
    else
      base.formatters()
    end
  end

  defp key_formatters(base) do
    if Module.open?(base) do
      Module.get_attribute(base, :__key_formatters__)
    else
      base.key_formatters()
    end
  end

  defp inject_code(content, injection) when is_tuple(injection),
    do: inject_code(content, [injection])
  defp inject_code(content, []),
    do: content
  defp inject_code(content, [injection|injections]) do
    nodes = case content do
      {:__block__, [], all} -> all
      any -> [any]
    end

    inject_code({:__block__, [], [injection|nodes]}, injections)
  end
end
