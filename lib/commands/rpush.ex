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
        :gen_tcp.send(client, "+#{length(values)}\r\n")
      existing_values when is_list(existing_values) ->
        new_values = existing_values ++ values
        IO.inspect(new_values, label: "Values being pushed to list #{inspect(existing_values)}")
        RedisCache.set(cache_pid, %{key => new_values})
        :gen_tcp.send(client, "+#{length(new_values)}\r\n")
    end
  end
end
