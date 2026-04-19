defmodule Commands.LLen do
  @behaviour Commands.Behaviour

  require Logger

  alias RedisCache


  @impl true
  def execute(client, [key, _value] = message, cache_pid) do
    Logger.info(client: client, message: message, command: "LLEN")

    case RedisCache.get(cache_pid, key) do
      nil ->
        :gen_tcp.send(client, ":0\r\n")

      existing_values when is_list(existing_values) ->
        :gen_tcp.send(client, ":#{length(existing_values)}\r\n")
    end
  end

  @impl true
  def execute(client, message, _cache_pid) do
    Logger.info(client: client, message: message, command: "LLEN")
    :gen_tcp.send(client, "-ERR wrong number of arguments for 'LLEN' command\r\n")
  end
end
