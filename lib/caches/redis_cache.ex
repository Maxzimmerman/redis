defmodule RedisCache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    data = %{}

    {:ok, data}
  end

  @impl true
  def handle_info({:delete, key}, state) do
    new_state = Map.drop(state, [key])
    {:noreply, new_state}
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    value = Map.get(state, key)
    new_state = Map.drop(state, [key])
    {:reply, value, new_state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    IO.inspect(state, label: "Current cache state")
    value = state[key]
    {:reply, value, state}
  end

  @impl true
  def handle_call({:add, key_value_pair}, _from, state) do
    [{key, value}] = Map.to_list(key_value_pair)
    new_state = Map.put(state, key, value)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:update, key_value_pair}, _from, state) do
    [{key, value}] = Map.to_list(key_value_pair)
    new_state = Map.put(state, key, Map.get(state, key) ++ value)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:update_prepand, key_value_pair}, _from, state) do
    [{key, value}] = Map.to_list(key_value_pair)
    new_state = Map.put(state, key, Map.get(state, key) ++ value)
    {:reply, :ok, new_state}
  end

  def set(pid, key_value_pair) do
    GenServer.call(pid, {:add, key_value_pair})
  end

  def update(pid, key_value_pair) do
    GenServer.call(pid, {:update, key_value_pair})
  end

  def update_prepend(pid, key_value_pair) do
    GenServer.call(pid, {:update_prepend, key_value_pair})
  end

  def set_with_exp(pid, key_value_pair, expiry) do
    [{key, _value}] = Map.to_list(key_value_pair)
    GenServer.call(pid, {:add, key_value_pair})
    delete_value_after_timeout(pid, key, expiry)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def get_range(pid, key, start_index, end_index) do
    case GenServer.call(pid, {:get, key}) do
      nil -> nil
      list when is_list(list) -> Enum.slice(list, start_index, end_index - start_index + 1)
    end
  end

  def get_length(pid, key) do
    case GenServer.call(pid, {:get, key}) do
      nil -> nil
      list when is_list(list) -> length(list)
    end
  end

  defp delete_value_after_timeout(pid, key, timeout) do
    IO.puts("Scheduling deletion of key '#{key}' after #{timeout} ms")
    Process.send_after(pid, {:delete, key}, timeout)
  end
end
