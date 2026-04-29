defmodule Commands.BLPop do
  @behaviour Commands.Behaviour
  @behaviour Events.Handler
  require Logger

  alias Events.Event
  alias Commands.BLPopRegistry

  # Timeout 0 = block indefinitely
  @impl true
  def execute(client, [key, "0"], _cache_pid) do
    BLPopRegistry.register(key, client, self())

    receive do
      {:blpop_result, _key, _element} -> :ok
    end
  end

  # Non-zero timeout
  @impl true
  def execute(client, [key, timeout], _cache_pid) do
    BLPopRegistry.register(key, client, self())
    timeout_ms = String.to_integer(timeout) * 1000

    receive do
      {:blpop_result, _key, _element} -> :ok
    after
      timeout_ms ->
        :gen_tcp.send(client, "*-1\r\n")
    end
  end

  # Called by EventDispatcher when an element is pushed to a list
  @impl true
  def handle_event(%Event{type: "element_added"} = event) do
    key = event.payload.list_key
    cache_pid = event.payload.cache_pid

    case BLPopRegistry.pop_waiter(key) do
      {:ok, {client_socket, pid}} ->
        case RedisCache.pop_left(key, "1", cache_pid) do
          [element] ->
            resp =
              "*2\r\n$#{byte_size(key)}\r\n#{key}\r\n$#{byte_size(element)}\r\n#{element}\r\n"

            :gen_tcp.send(client_socket, resp)
            send(pid, {:blpop_result, key, element})

          _ ->
            nil
        end

        :ok

      :empty ->
        :ok
    end
  end
end
