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
  def handle_call({:delete, key}, _from, state) do
    value = Map.get(state, key)
    new_state = Map.drop(state, [key])
    {:reply, value, new_state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    value = state[key]
    {:reply, value, state}
  end

  @impl true
  def handle_call({:add, key_value_pair}, _from, state) do
    [{key, value}] = Map.to_list(key_value_pair)
    new_state = Map.put(state, key, value)
    {:reply, :ok, new_state}
  end

  @doc """
  list operations
  """

  @impl true
  def handle_call({:update, key_value_pair}, _from, state) do
    [{key, value}] = Map.to_list(key_value_pair)
    new_state = Map.put(state, key, Map.get(state, key) ++ value)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:update_prepend, key_value_pair}, _from, state) do
    [{key, value}] = Map.to_list(key_value_pair)
    new_values = Enum.reverse(value)
    new_state = Map.put(state, key, new_values ++ Map.get(state, key))
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:pop_list_element, key}, _from, state) do
    [item_to_remove | updated_list] = state[key]
    new_state = Map.put(state, key, updated_list)
    {:reply, item_to_remove, new_state}
  end

  @impl true
  def handle_call({:pop_list_elements, key, number_to_remove}, _from, state) do
    IO.inspect(number_to_remove, label: "Number to remove")
    to_remove = Enum.take(state[key], String.to_integer(number_to_remove))
    updated_list = Enum.drop(state[key], String.to_integer(number_to_remove))
    new_state = Map.put(state, key, updated_list)
    {:reply, to_remove, new_state}
  end

  @doc """
  public API
  """

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
    case GenServer.call(pid, {:get, key}) do
      nil -> nil
      value -> value
    end
  end

  def pop_list_element(key, pid) do
    case GenServer.call(pid, {:pop_list_element, key}) do
      nil -> nil
      value -> value
    end
  end

  def pop_list_elements(key, number_to_remove, pid) do
    case GenServer.call(pid, {:pop_list_elements, key, number_to_remove}) do
      nil -> nil
      values -> values
    end
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
    Process.send_after(pid, {:delete, key}, timeout)
  end
end
