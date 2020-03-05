defmodule Entitiex.Exposure.Handler do
  defmacro __using__(_opts \\ []) do
    quote location: :keep do
      @behaviour Entitiex.Exposure.Handler

      def key(_exposure, key),
        do: key

      def value(_exposure, value),
        do: value

      def setup(_entity, _opts),
        do: {__MODULE__, []}

      defoverridable [key: 2, value: 2, setup: 2]
    end
  end

  @callback value(exposure :: Entitiex.Types.exposure(), value :: any()) :: any()
  @callback key(exposure :: Entitiex.Types.exposure(), key :: any()) :: any()
end
