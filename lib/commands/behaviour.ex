defmodule Commands.Behaviour do
  @callback execute(client :: any(), args :: list(), cache_pid :: pid()) :: any()
end
