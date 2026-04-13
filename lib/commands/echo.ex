defmodule Commands.Echo do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message) do
    Logger.info(client: client, message: message)
    msg = List.first(message)
    :gen_tcp.send(client, "$#{byte_size(msg)}\r\n#{msg}\r\n")
  end
end
