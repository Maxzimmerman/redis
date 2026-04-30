defmodule Commands.XADD do
  @behaviour Commands.Behaviour

  @impl true
  def execute(client, message, cache_pid) do
    IO.inspect(message)
  end
end
