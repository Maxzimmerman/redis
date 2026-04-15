defmodule Commands.Set do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, key_values) do
    Logger.info(client: client, message: message)
    IO.inspect(message, label: "SET command received with args")
    # For simplicity, we just acknowledge the SET command without actual storage
    :gen_tcp.send(client, "+OK\r\n")
    %{List.first(message) => List.last(message) | key_values}
  end
end
