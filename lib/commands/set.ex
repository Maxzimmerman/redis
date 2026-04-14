defmodule Commands.Set do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message) do
    Logger.info(client: client, message: message)
    # For simplicity, we just acknowledge the SET command without actual storage
    :gen_tcp.send(client, "+OK\r\n")
  end
end
