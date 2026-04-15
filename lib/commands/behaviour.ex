defmodule Commands.Behaviour do
  @callback execute(client :: any(), args :: list(), key_values :: map()) :: any()
end
