defmodule Commands.Set do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) when length(message) == 2 do
    Logger.info(client: client, message: message)
    # For simplicity, we just acknowledge the SET command without actual storage
    :gen_tcp.send(client, "+OK\r\n")
    RedisCache.set(cache_pid, %{List.first(message) => List.last(message)})
  end

  def execute(client, message, cache_pid) do
    Logger.error(client: client, message: "Invalid SET command format")
    :gen_tcp.send(client, "+OK\r\n")
    [key, value, _, expiry] = message
    RedisCache.set_with_exp(cache_pid, %{key => value}, String.to_integer(expiry))
  end
end
