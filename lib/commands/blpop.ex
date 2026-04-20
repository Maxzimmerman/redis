defmodule Command.BLPop do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
  require Logger

  alias Events.Event

  def execute(client, message, _key_values) do
    Logger.info(client: client, message: message)
    msg = List.first(message)
    :gen_tcp.send(client, "$#{byte_size(msg)}\r\n#{msg}\r\n")
  end

  def handle_event(%Event{type: "element_added", payload: payload}) do
    Logger.info("Received event for list #{payload.list_key} with new element: #{payload.element}")
    :ok
  end
end
