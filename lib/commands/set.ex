defmodule Commands.Set do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, key_values) do
    Logger.info(client: client, message: message)
    IO.inspect(message, label: "SET command message")
    # For simplicity, we just acknowledge the SET command without actual storage
    :gen_tcp.send(client, "+OK\r\n")
    Map.put(key_values, List.first(message), List.last(message))
  end
end
