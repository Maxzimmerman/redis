defmodule Commands.BLPopRegistry do
  @moduledoc """
  Tracks which processes are waiting for BLPOP on which keys.
  Stores a queue per key so the longest-waiting client is served first.
  """

  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc "Register a waiting BLPOP client. Returns :ok."
  def register(key, client_socket, pid) do
    Agent.update(__MODULE__, fn state ->
      queue = Map.get(state, key, :queue.new())
      Map.put(state, key, :queue.in({client_socket, pid}, queue))
    end)
  end

  @doc "Pop the oldest waiter for a key. Returns {:ok, {client_socket, pid}} or :empty."
  def pop_waiter(key) do
    Agent.get_and_update(__MODULE__, fn state ->
      case Map.get(state, key) do
        nil ->
          {:empty, state}

        queue ->
          case :queue.out(queue) do
            {{:value, waiter}, new_queue} ->
              new_state =
                if :queue.is_empty(new_queue),
                  do: Map.delete(state, key),
                  else: Map.put(state, key, new_queue)

              {{:ok, waiter}, new_state}

            {:empty, _} ->
              {:empty, Map.delete(state, key)}
          end
      end
    end)
  end
end
