defmodule Commands.RPush do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "RPUSH")

    :gen_tcp.send(client, "+OK\r\n")
    [key | values] = message

    IO.inspect(%{key => [values: values]}, label: "RPUSH command parsed")
    RedisCache.set(cache_pid, %{key => values})
  end
end
