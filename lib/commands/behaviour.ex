defmodule Commands.Behaviour do
  @callback handle_client_async(client :: any(), args :: list()) :: any()
end
