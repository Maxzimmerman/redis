defmodule Commands.LPush do
  @behaviour Commands.Behaviour
  require Logger

  alias Events.EventDispatcher
  alias Events.ItemPushedToList
  alias Events.ItemPushedToList.Payload

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "RPUSH")

    [key | values] = message

    case RedisCache.get(cache_pid, key) do
      nil ->
        new_list = :queue.from_list(values)
        RedisCache.set(cache_pid, %{key => new_list})
        send_event(key, List.first(values), cache_pid, client)
        :gen_tcp.send(client, ":#{length(values)}\r\n")

      {_existing_values, _} ->
        RedisCache.update_prepend(cache_pid, %{key => values})
        updated_list = RedisCache.get(cache_pid, key)
        send_event(key, List.first(values), cache_pid, client)
        :gen_tcp.send(client, ":#{:queue.len(updated_list)}\r\n")
    end
  end

  def send_event(key, element, cache_pid, client) do
    payload = %Payload{
      list_key: key,
      element: element,
      cache_pid: cache_pid,
      client: client
    }

    event = ItemPushedToList.new(payload)
    EventDispatcher.dispatch(event)
  end
end
