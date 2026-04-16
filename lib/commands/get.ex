defmodule Commands.Get do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message)
    key = List.first(message)
    value = GenServer.call(cache_pid, {:get, key})

    IO.inspect(value, label: "GET value for key '#{key}'")

    if value do
      :gen_tcp.send(client, "$#{byte_size(value)}\r\n#{value}\r\n")
    else
      IO.inspect("Key '#{key}' not found", label: "GET command")
      :gen_tcp.send(client, "$-1\r\n")
    end
  end
end
