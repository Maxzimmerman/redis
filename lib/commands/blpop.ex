defmodule Commands.BLPop do
  @moduledoc """
  Exactly right. One small correction — the RPUSH doesn't send the event "to the blocked process." The event handler runs in the RPUSH process, and it:

  1. Asks the Agent: "who's been waiting longest for this key?"
  2. Agent returns {socket, pid}
  3. RPUSH process uses socket to send the TCP response to the right client
  4. RPUSH process uses pid to send(pid, {:blpop_result, ...}) — this is what wakes up the blocked process

  Two separate things: the socket is for talking to the client over TCP, the pid is for unblocking the frozen process so it can loop back to handle_client_async and read the next command.
  """
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
    {seconds, _} = Float.parse(timeout)
    timeout_ms = trunc(seconds * 1000)

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
