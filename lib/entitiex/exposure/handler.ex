defmodule Entitiex.Exposure.Handler do
  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      @behaviour Entitiex.Exposure.Handler

      def extract_value(%{entity: entity, attribute: attribute}, struct) do
        if function_exported?(entity, attribute, 1) do
          apply(entity, attribute, [struct])
        else
          Map.get(struct, attribute)
        end
      end

      def expose?(%{conditions: conditions}, struct, value),
        do: Entitiex.Conditions.run(conditions, struct, value)

      def key(exposure),
        do: {:ok, exposure.key}

      def value(_exposure, _struct),
        do: :skip

      defoverridable [expose?: 3, key: 1, value: 2]
    end
  end

  @callback expose?(exposure :: %Entitiex.Exposure{}, struct :: any(), value :: any()) :: boolean()
  @callback value(exposure :: %Entitiex.Exposure{}, value :: any()) :: {:ok, any()} | atom()
  @callback key(exposure :: %Entitiex.Exposure{}) :: {:ok, atom()}
end
