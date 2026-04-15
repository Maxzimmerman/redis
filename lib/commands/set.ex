defmodule Commands.Set do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, key_values) do
    Logger.info(client: client, message: message)
    IO.inspect(message, label: "SET command received with args")
    # For simplicity, we just acknowledge the SET command without actual storage
    :gen_tcp.send(client, "+OK\r\n")
    IO.inspect(List.first(message), label: "Key to set")
    IO.inspect(List.last(message), label: "Value to set")
    Map.put(key_values, List.first(message), List.last(message))
  end
end
