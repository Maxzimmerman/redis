defmodule Commands.LPush do
  @behaviour Commands.Behaviour
  require Logger

  @impl true
  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "LPUSH")

    [key | values] = message

    case RedisCache.get(cache_pid, key) do
      nil ->
        new_list = :queue.from_list(Enum.reverse(values))
        RedisCache.set(cache_pid, %{key => new_list})
        :gen_tcp.send(client, ":#{length(values)}\r\n")

      {_existing_values, _} ->
        RedisCache.update_prepend(cache_pid, %{key => Enum.reverse(values)})
        updated_list = RedisCache.get(cache_pid, key)
        :gen_tcp.send(client, ":#{:queue.len(updated_list)}\r\n")
    end
  end
end
