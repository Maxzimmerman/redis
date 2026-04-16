defmodule Commands.Get do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message)
    key = List.first(message)
    value = RedisCache.get(cache_pid, key)

    if value do
      :gen_tcp.send(client, "$#{byte_size(value)}\r\n#{value}\r\n")
    else
      :gen_tcp.send(client, "$-1\r\n")
    end
  end
end
