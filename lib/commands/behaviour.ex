defmodule Commands.Behaviour do
  @callback handle_client_async(socket :: any(), client :: any(), args :: list()) :: any()
end
