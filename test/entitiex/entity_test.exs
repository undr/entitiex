defmodule Entitiex.EntityTest do
  use ExUnit.Case

  alias Entitiex.Exposure
  alias Entitiex.Entity

  defmodule TestEntity do
    use Entity

    format_keys :to_s
    format_keys :lcamelize

    expose :attr1

    with_options expose_nil: false do
      expose [:attr2, :attr3], format: :to_s, format_key: :to_s
      expose :attr4, if: :should_expose?
    end

    inline :attr5 do
      expose :nested1
    end

    nesting :attr6 do
      expose :nested2
    end

    def should_expose?(_struct, _value),
      do: true
  end

  describe "macros" do
    test "format_keys" do
      assert TestEntity.key_formatters() == [&Entitiex.Formatter.to_s/1, &Entitiex.Formatter.lcamelize/1]
    end

    test "exposures" do
      assert TestEntity.exposures() == [
        %Entitiex.Exposure{
          attribute: :attr1,
          conditions: [],
          entity: Entitiex.EntityTest.TestEntity,
          handlers: [Entitiex.Exposure.DefaultHandler],
          key: :attr1,
          opts: [merge: false]
        },
        %Entitiex.Exposure{
          attribute: :attr2,
          conditions: [&Entitiex.Conditions.expose_nil?/2],
          entity: Entitiex.EntityTest.TestEntity,
          handlers: [Entitiex.Exposure.DefaultHandler, Entitiex.Exposure.FormattedHandler],
          key: :attr2,
          opts: [format: [&Entitiex.Formatter.to_s/1], format_key: [&Entitiex.Formatter.to_s/1], merge: false]
        },
        %Entitiex.Exposure{
          attribute: :attr3,
          conditions: [&Entitiex.Conditions.expose_nil?/2],
          entity: Entitiex.EntityTest.TestEntity,
          handlers: [Entitiex.Exposure.DefaultHandler, Entitiex.Exposure.FormattedHandler],
          key: :attr3,
          opts: [format: [&Entitiex.Formatter.to_s/1], format_key: [&Entitiex.Formatter.to_s/1], merge: false]
        },
        %Entitiex.Exposure{
          attribute: :attr4,
          conditions: [&Entitiex.Conditions.expose_nil?/2, &Entitiex.EntityTest.TestEntity.should_expose?/2],
          entity: Entitiex.EntityTest.TestEntity,
          handlers: [Entitiex.Exposure.DefaultHandler],
          key: :attr4,
          opts: [merge: false]
        },
        %Entitiex.Exposure{
          attribute: :attr5,
          conditions: [],
          entity: Entitiex.EntityTest.TestEntity,
          handlers: [Entitiex.Exposure.DefaultHandler, Entitiex.Exposure.EntityHandler],
          key: :attr5,
          opts: [using: Entitiex.EntityTest.TestEntity.CodeGen.Nesting1, merge: false]
        },
        %Entitiex.Exposure{
          attribute: nil,
          conditions: [],
          entity: Entitiex.EntityTest.TestEntity,
          handlers: [Entitiex.Exposure.DefaultHandler, Entitiex.Exposure.EntityHandler],
          key: :attr6,
          opts: [using: Entitiex.EntityTest.TestEntity.CodeGen.Nesting0, merge: false]
        }
      ]
    end
  end
end
