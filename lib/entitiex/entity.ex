defmodule Entitiex.Entity do
  @moduledoc """
  Defines a entity module.

  ## Example

      defmodule UserEntity do
        use Entitiex.Entity

        expose [:first_name, :last_name], format: :to_s
        expose :contacts, using: ContactEntity, if: :owner_is_admin?
        expose [:registered_at, :updated_at], format: &DateTimeFormatter.format/1

        def owner_is_admin?(_struct, _value, %{owner: %{admin: admin}}),
          do: admin
        def owner_is_admin?(_struct, _value, _context),
          do: false
      end

  Entity module provides a `represent` function, which allow to transform given struct into new structure.

      iex> UserEntity.represent(struct)
      %{first_name: "...", ...}

      iex> UserEntity.represent([struct])
      [%{first_name: "...", ...}]

      iex> UserEntity.represent(struct, root: :users, extra: [meta: %{}])
      %{users: %{first_name: "...", ...}, meta: %{}}

      iex> UserEntity.represent(struct, root: :users, context: [owner: %User{admin: true}])
      %{users: %{first_name: "...", contacts: %{...}, ...}}
  """
  alias Entitiex.Exposure
  alias Entitiex.Types

  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      @__exposures__ []
      @__pre_exposures__ []
      @__shared_options__ []
      @__key_formatters__ []
      @__pre_key_formatters__ []
      @__root__ [singular: nil, plural: nil]

      Module.register_attribute(__MODULE__, :__exposures__, accumulate: true)
      Module.register_attribute(__MODULE__, :__pre_exposures__, accumulate: true)
      Module.register_attribute(__MODULE__, :__pre_key_formatters__, accumulate: true)

      alias Entitiex.Exposure
      alias Entitiex.Utils

      import unquote(__MODULE__), only: [
        expose: 2, expose: 1, root: 2, root: 1, format_keys: 1,
        nesting: 2, nesting: 3, inline: 2, inline: 3, with_options: 2
      ]

      @before_compile unquote(__MODULE__)

      @doc """
      Transform a struct into the structure defined in the entity module.
      It gives struct or list of structs as a first argument and options as a
      second. The result can consist of two parts: inner and outer structure.
      The inner structure is described in the entity module. The outer
      structure exists only if `:root` option is defined and contains inner
      structure under the root key and some additional data if `extra` option
      is defined.

      Inner:

          %{name: "Jon Snow"}

      Outer:

          %{root_key: %{name: "Jon Snow"}}

      Outer with extra:

          %{root_key: %{name: "Jon Snow"}, meta: %{data: %{...}}}

      Available options:

        - `:root` - it allows us to define root key for final structure.
        - `:extra` - it allows us to define extra structure which will be
        merged into outer map. This option will be omitted if `:root` option is
        not defined. That's because there is no outer structure without
        `:root` option.
        - `:context` - it allows us to define the context of the process of
        representation. In other words, it allows setting runtime options for
        the particular representation.
      """
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

      defp do_represent(struct, :nil, context, extra),
        do: serializable_map(struct, context)
      defp do_represent(struct, root, context, extra) do
        extra
        |> Utils.transform_keys(&(format_key(&1)))
        |> Map.put(format_key(root), serializable_map(struct, context))
      end

      @doc """
      Transform a struct into the inner structure.
      """
      def serializable_map(structs, context \\ %{})
      def serializable_map(structs, context) when is_list(structs),
        do: Enum.map(structs, fn (struct) -> serializable_map(struct, context) end)
      def serializable_map(struct, context) when is_map(struct) do
        Enum.reduce(exposures(), %{}, fn (exposure, acc) ->
          with key <- Exposure.key(exposure) do
            case Exposure.value(exposure, struct, context) do
              {:merge, value} -> Map.merge(acc, value)
              {:put, value} -> Map.put(acc, key, value)
              :skip -> acc
            end
          end
        end)
      end
      def serializable_map(struct, _context),
        do: struct

      defoverridable [serializable_map: 1]
    end
  end

  defmacro __before_compile__(_env) do
    exposures = Enum.map(Module.get_attribute(__CALLER__.module, :__pre_exposures__), fn {attribute, opts, block} ->
      nesting = Keyword.get(opts, :nesting, false)

      quote location: :keep do
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

        @__exposures__ Entitiex.Exposure.new(
          __ENV__.module,
          unquote(attribute),
          opts
        )
      end
    end)

    key_formatters = Module.get_attribute(__CALLER__.module, :__pre_key_formatters__)
    key_formatters = Entitiex.Formatter.normalize(key_formatters, __CALLER__.module) |> Enum.reverse()
    key_formatters = quote location: :keep do
      @__key_formatters__ unquote(key_formatters)
    end

    Module.delete_attribute(__CALLER__.module, :__pre_exposures__)
    Module.delete_attribute(__CALLER__.module, :__shared_options__)
    Module.delete_attribute(__CALLER__.module, :__pre_key_formatters__)

    quote location: :keep do
      unquote(key_formatters)
      unquote(exposures)

      def key_formatters do
        @__key_formatters__
      end

      def exposures do
        @__exposures__
      end

      def format_key(key) do
        Entitiex.Formatter.format(key_formatters(), key)
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
      quote do
        @__pre_exposures__ {unquote(attribute), Entitiex.Entity.reduce_options(__ENV__.module, unquote(opts)), unquote(Macro.escape(block))}
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
      @__pre_key_formatters__ unquote(func)
    end
  end

  defmacro with_options(opts, [do: block]) do
    quote location: :keep do
      @__shared_options__ [unquote(opts) | @__shared_options__]

      try do
        unquote(block)
      after
        @__shared_options__ tl(@__shared_options__)
      end
    end
  end

  @doc false
  @spec reduce_options(module(), Types.exp_opts()) :: Types.exp_opts()
  def reduce_options(base, opts) do
    shared_opts = Module.get_attribute(base, :__shared_options__, [])
    Enum.reduce([opts|shared_opts], &Entitiex.Options.merge/2)
  end

  @doc false
  @spec generate_module(module(), any(), any()) :: module()
  def generate_module(base, content, env) do
    index = base
    |> exposures()
    |> length()

    key_formatters = base
    |> key_formatters()
    |> Enum.map(fn key -> quote(do: @__key_formatters__ unquote(key)) end)

    content = content
    |> inject_code(key_formatters)
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
