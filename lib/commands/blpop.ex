defmodule Commands.BLPop do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
  require Logger

  alias Events.Event
  alias RedisCache
  alias Events.Index

  # send listening event to rpush and lpush
  @impl true
  def execute(client, [key, 0] = message, _cache_pid) do
    Logger.info(client: client, message: message)
    msg = List.first(message)
    :gen_tcp.send(client, "$#{byte_size(msg)}\r\n#{msg}\r\n")
  end

  # if timout is reached just return
  @impl true
  def execute(client, [_key, timeout] = message, _cache_pic) do
    :timer.apply_after(timeout, __MODULE__, :delete_task, [task_id])
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

  defp delete_task(task_id) do
    Index.delete_taks(task_id)
  end
end
