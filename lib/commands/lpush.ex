defmodule Commands.LPush do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
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
        :gen_tcp.send(client, ":#{length(values)}\r\n")

      {_existing_values, _} ->
        RedisCache.update_prepend(cache_pid, %{key => values})
        updated_list = RedisCache.get(cache_pid, key)
        :gen_tcp.send(client, ":#{:queue.len(updated_list)}\r\n")
    end
  end

  # if element should be removed with blpop just send event to blpop to remove it immediately and send it to the client
  @impl true
  def handle_event(%Events.Event{type: "listen_for_pushed_element"} = event) do
    send_event(event.payload.list_key, event.payload.cache_pid, event.payload.client)
  end

  def send_event(key, cache_pid, client) do
    payload = %Payload{
      list_key: key,
      element: nil,
      cache_pid: cache_pid,
      client: client
    }

    event = ItemPushedToList.new(payload)
    EventDispatcher.dispatch(event)
  end
end
