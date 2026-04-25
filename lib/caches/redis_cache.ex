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
    IO.inspect(state)
    new_state = Map.put(state, key, value)
    {:reply, :ok, new_state}
  end

  @doc """
  list operations
  """

  @impl true
  def handle_call({:update, key_value_pair}, _from, state) do
    [{key, values}] = Map.to_list(key_value_pair)
    IO.inspect(:queue.from_list(values))
    IO.inspect(Map.get(state, key))
    new_list = :queue.join(Map.get(state, key), :queue.from_list(values))
    new_state = Map.put(state, key, new_list)
    IO.inspect(new_state)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:update_prepend, key_value_pair}, _from, state) do
    [{key, value}] = Map.to_list(key_value_pair)
    new_list = :queue.join(:queue.from_list(value), Map.get(state, key))
    new_state = Map.put(state, key, new_list)
    IO.inspect(new_state)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:pop_right, key, number_to_remove}, _from, state) do
    items_removed = Enum.slice(:queue.to_list(state[key]), 0, number_to_remove)
    number_to_remove = String.to_integer(number_to_remove)
    updated_queue = pop_right(number_to_remove, state[key])
    updated_state = Map.put(state, key, updated_queue)
    {:reply, items_removed, updated_state}
  end

  @impl true
  def handle_call({:pop_left, key, number_to_remove}, _from, state) do
    number_to_remove = String.to_integer(number_to_remove)
    items_removed = Enum.slice(:queue.to_list(state[key]), 0, number_to_remove)

    updated_queue = pop_left_queue(number_to_remove, state[key])

    new_state = Map.put(state, key, updated_queue)

    {:reply, items_removed, new_state}
  end

  @impl true
  def handle_call({:get_length, key}, _form, state) do
    case state[key] do
      nil -> {:reply, nil, state}
      list -> {:reply, :queue.len(list), state}
    end
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

  def pop_right(key, number_to_remove, pid) do
    case GenServer.call(pid, {:pop_right, key, number_to_remove}) do
      nil -> nil
      values -> values
    end
  end

  def pop_left(key, number_to_remove, pid) do
    case GenServer.call(pid, {:pop_left, key, number_to_remove}) do
      nil -> nil
      values -> values
    end
  end

  def get_range(pid, key, start_index, end_index) do
    case GenServer.call(pid, {:get, key}) do
      nil ->
        nil

      list ->
        elements_in_range =
          :queue.fold(
            fn element, acc ->
              [element | acc]
            end,
            [],
            list
          )

        IO.inspect(elements_in_range)
        list = :queue.to_list(list)
        Enum.slice(list, start_index, end_index - start_index + 1)
    end
  end

  def get_length(pid, key) do
    case GenServer.call(pid, {:get_length, key}) do
      nil -> nil
      length -> length
    end
  end

  defp delete_value_after_timeout(pid, key, timeout) do
    Process.send_after(pid, {:delete, key}, timeout)
  end

  defp pop_left_queue(0, queue), do: queue

  defp pop_left_queue(count, queue) do
    {{:value, _}, updated_queue} = :queue.out(queue)
    pop_left_queue(count - 1, updated_queue)
  end

  defp pop_right(0, queue), do: queue

  defp pop_right(count, queue) do
    {{:value, _}, updated_queue} = :queue.out_r(queue)
    pop_right(count - 1, updated_queue)
  end
end
