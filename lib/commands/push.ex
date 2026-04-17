defmodule Commands.Push do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message)

    :gen_tcp.send(client, "+OK\r\n")
    [key | values] = message

    RedisCache.set(cache_pid, %{key => values})
  end
end
