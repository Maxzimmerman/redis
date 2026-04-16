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
    value = Map.get(state, key)
    {:reply, value, state}
  end

  @impl true
  def handle_call({:add, key_value_pair}, _from, state) do
    new_state = Map.put(state, key_value_pair._, key_value_pair._)
    {:noreply, key_value_pair, new_state}
  end

  def set(pid, %{_: _} = key_value_pair) do
    GenServer.cast(pid, {:add, key_value_pair})
  end

  def set_with_exp(pid, %{_: _} = key_value_pair, expiry) do
    GenServer.cast(pid, {:add, key_value_pair})
    delete_value_after_timeout(pid, key_value_pair._, expiry)
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  defp delete_value_after_timeout(key, timeout) do
    Process.send_after(self(), {:delete, key}, timeout)
  end
end
