defmodule Commands.BLPop do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
  require Logger

  alias Events.Event
  alias RedisCache

  # send listening event to rpush and lpush
  @impl true
  def execute(_client, [_key, 0], _cache_pid), do: :ok

  # if timout is reached just return
  @impl true
  def execute(client, [_key, timeout], _cache_pid) do
    IO.inspect("Executing BLPOP command with timeout: #{timeout}")
    :timer.apply_after(String.to_integer(timeout) * 1000, __MODULE__, :close_connection, [client])
  end

  # wait for element added events to remove it immediately and send it to the client
  @impl true
  def handle_event(%Event{type: "element_added"} = event) do
    Logger.info(
      "Received event for list #{event.payload.list_key} with new element: #{event.payload.element}"
    )

    case RedisCache.pop_left(event.payload.list_key, "1", event.payload.cache_pid) do
      nil ->
        :gen_tcp.send(event.payload.client, "$*\r\n")

      element ->
        IO.inspect(element, label: "Popped element from list #{event.payload.list_key}")
        IO.inspect(event)

        :gen_tcp.send(
          event.payload.client,
          "$*2\r\n$#{byte_size(event.payload.list_key)}\r\n#{event.payload.list_key}\r\n$#{byte_size(element)}\r\n#{element}\r\n"
        )
    end
  end

  def close_connection(client) do
    :gen_tcp.send(client, "*-1\r\n")
  end
end
