defmodule Commands.RPush do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "RPUSH")

    [key | values] = message

    case RedisCache.get(cache_pid, key) do
      nil ->
        RedisCache.set(cache_pid, %{key => values})
        :gen_tcp.send(client, "+#{1}\r\n")
      existing_values when is_list(existing_values) ->
        new_values = existing_values ++ values
        RedisCache.set(cache_pid, %{key => new_values})
        :gen_tcp.send(client, "+#{length(new_values)}\r\n")
    end
  end
end
