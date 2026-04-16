defmodule Commands.Set do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, key_values) when length(message) == 2 do
    Logger.info(client: client, message: message)
    IO.inspect(message, label: "SET command message")
    # For simplicity, we just acknowledge the SET command without actual storage
    :gen_tcp.send(client, "+OK\r\n")
    Map.put(key_values, List.first(message), List.last(message))
  end

  def execute(client, message, key_values) do
    Logger.error(client: client, message: "Invalid SET command format")
    :gen_tcp.send(client, "+OK\r\n")
    [key, value | _] = message
     Map.put(key_values, key, value)
  end
end
