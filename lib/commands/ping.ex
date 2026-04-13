defmodule Commands.Ping do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message) do
    Logger.info(client: client, message: message)
    :gen_tcp.send(client, "+PONG\r\n")
  end
end
