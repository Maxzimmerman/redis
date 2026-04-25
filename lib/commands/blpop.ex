defmodule Commands.BLPop do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
  require Logger

  alias Events.Event
  alias RedisCache

  @impl true
  def execute(client, [key, 0] = message, _cache_pid) do
    Logger.info(client: client, message: message)
    msg = List.first(message)
    :gen_tcp.send(client, "$#{byte_size(msg)}\r\n#{msg}\r\n")
  end

  @impl true
  def execute(client, [key, timeout] = message, _cache_pic) do
    Logger.info(client: client, message: message)
    msg = List.first(message)
    :gen_tcp.send(client, "$#{byte_size(msg)}\r\n#{msg}\r\n")
  end

  @impl true
  def handle_event(%Event{type: "element_added"} = event) do
    Logger.info(
      "Received event for list #{event.payload.list_key} with new element: #{event.payload.element}"
    )

    case RedisCache.pop_left(event.payload.list_key, 1, self()) do
      nil ->
        Logger.info("No elements to pop from list #{event.payload.list_key}")

      element ->
        Logger.info("Popped element '#{element}' from list #{event.payload.list_key}")
    end
  end
end
