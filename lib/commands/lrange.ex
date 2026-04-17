defmodule Commands.LRange do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, _cache_pid) do
    Logger.info(client: client, message: message, command: "LRange")

     [key | values] = message

     :gen_tcp.send(client, "+OK\r\n")

    :gen_tcp.send(client, "+OK\r\n")
  end
end
