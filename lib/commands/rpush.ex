defmodule Commands.RPush do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "RPUSH")

    [key | values] = message

    case RedisCache.get(cache_pid, key) do
      nil ->
        RedisCache.set(cache_pid, %{key => values})
        IO.inspect(values, label: "Values being pushed to new list")
        :gen_tcp.send(client, ":#{length(values)}\r\n")
      existing_values when is_list(existing_values) ->
        RedisCache.update(cache_pid, %{key => values})
        updated_list = RedisCache.get(cache_pid, key)
        :gen_tcp.send(client, ":#{length(updated_list)}\r\n")
    end
  end
end
