defmodule Commands.BLPop do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
  require Logger

  alias Events.Event

  @impl true
  def execute(client, message, _key_values) do
    Logger.info(client: client, message: message)
    msg = List.first(message)
    :gen_tcp.send(client, "$#{byte_size(msg)}\r\n#{msg}\r\n")
  end

  @impl true
  def handle_event(%Event{type: "element_added"} = event) do
    Logger.info("Received event for list #{event.payload.list_key} with new element: #{event.payload.element}")
    :ok
  end
end
