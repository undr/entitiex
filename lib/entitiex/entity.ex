defmodule Entitiex.Entity do
  alias Entitiex.Exposure

  # @options [:as, :if, :unless, :using, :func, :documentation, :format_with, :expose_nil, :override]

  defmacro __using__(_opts \\ []) do
    quote do
      @__exposures__ []
      @__formatters__ []
      @__key_formatters__ []
      @__root__ [singular: nil, plural: nil]

      Module.register_attribute(__MODULE__, :__exposures__, accumulate: true)
      Module.register_attribute(__MODULE__, :__formatters__, accumulate: true)
      Module.register_attribute(__MODULE__, :__key_formatters__, accumulate: true)

      alias Entitiex.Exposure

      import unquote(__MODULE__), only: [expose: 2, expose: 1, root: 2, root: 1, format_with: 2, format_keys: 1]
      @before_compile unquote(__MODULE__)

      def represent(struct, opts \\ [])
      def represent(structs, opts) when is_list(structs) do
        inner = serializable_map(structs)

        case get_root(opts, :plural) do
          nil -> inner
          root_key -> %{format_key(root_key) => inner}
        end
      end
      def represent(struct, opts) do
        inner = serializable_map(struct)

        case get_root(opts, :singular) do
          nil -> inner
          root_key -> %{format_key(root_key) => inner}
        end
      end

      def serializable_map(structs) when is_list(structs),
        do: Enum.map(structs, fn (struct) -> serializable_map(struct) end)
      def serializable_map(struct) when is_map(struct) do
        Enum.reduce(exposures(), %{}, fn (exposure, acc) ->
          with key <- Exposure.key(exposure),
               {:ok, value} <- Exposure.value(exposure, struct) do
            Map.put(acc, key, value)
          else
            _ -> acc
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

      def exposures do
        @__exposures__
      end

      def format_key(key) do
        @__key_formatters__
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
    do: expose_attributes(attributes, __CALLER__, opts)

  defp expose_attributes(attribute, caller, opts) when is_binary(attribute) or is_atom(attribute),
    do: expose_attributes([attribute], caller, opts)
  defp expose_attributes(attributes, caller, opts) when is_list(attributes) do
    Enum.map(attributes, fn (attribute) ->
      entity = caller.module
      key = Keyword.get(opts, :as, attribute)
      conditions = Entitiex.Conditions.compile(opts)
      conditions = quote do: unquote(Macro.escape(conditions))
      {handlers, opts} = Entitiex.Exposure.handlers(opts)

      quote do
        @__exposures__ %Entitiex.Exposure{
          conditions: unquote(Macro.escape(conditions)),
          attribute: unquote(attribute),
          handlers: unquote(handlers),
          entity: unquote(entity),
          opts: unquote(opts),
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
end
