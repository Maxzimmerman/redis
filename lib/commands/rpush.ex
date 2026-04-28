defmodule Commands.RPush do
  @behaviour Commands.Behaviour
  require Logger

  alias Events.ItemPushedToList
  alias Events.ItemPushedToList.Payload

  @impl true
  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "RPUSH")

    [key | values] = message

    case RedisCache.get(cache_pid, key) do
      nil ->
        new_list = :queue.from_list(values)
        RedisCache.set(cache_pid, %{key => new_list})
        IO.inspect(client, label: "Client")
        send_event(key, List.first(values), cache_pid, client)
        :gen_tcp.send(client, ":#{length(values)}\r\n")

      {_existing_values, _} ->
        RedisCache.update(cache_pid, %{key => values})
        updated_list = RedisCache.get(cache_pid, key)
        IO.inspect(client, label: "Client")
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

    IO.inspect(payload, label: "Event Payload")

    event = ItemPushedToList.new(payload)
    Events.EventDispatcher.dispatch(event)
  end
end
