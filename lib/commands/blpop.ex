defmodule Commands.BLPop do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
  require Logger

  alias Events.Event
  alias RedisCache

  # send listening event to rpush and lpush
  @impl true
  def execute(client, [key, 0] = message, _cache_pid) do
    Logger.info(client: client, message: message)
    msg = List.first(message)
    :gen_tcp.send(client, "$#{byte_size(msg)}\r\n#{msg}\r\n")
  end

  # if timout is reached just return
  @impl true
  def execute(client, [_key, timeout], _cache_pid) do
    :timer.apply_after(timeout, __MODULE__, :close_connection, [client])
  end

  # wait for element added events to remove it immediately and send it to the client
  @impl true
  def handle_event(%Event{type: "element_added"} = event) do
    Logger.info(
      "Received event for list #{event.payload.list_key} with new element: #{event.payload.element}"
    )

    case RedisCache.pop_left(event.payload.list_key, 1, self()) do
      nil ->
        :gen_tcp.send(event.payload.client, "$*\r\n")

      element ->
        :gen_tcp.send(
          event.payload.client,
          "$*2\r\n$#{byte_size(event.payload.list_key)}\r\n#{event.payload.list_key}\r\n$#{byte_size(element)}\r\n#{element}\r\n"
        )
    end
  end

  def close_connection(client) do
    :gen_tcp.send(client, "$*-1\r\n")
    :gen_tcp.close(client)
  end
end
