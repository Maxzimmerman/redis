defmodule Commands.Behaviour do
  @callback execute(client :: any(), args :: list()) :: any()
end
