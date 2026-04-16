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
  def handle_call(:delete, _from, state) do
    [deleted | new_state] = state
    {:reply, deleted, new_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:add, key_value_pair}, state) do
    new_state = [key_value_pair | state]
    {:noreply, new_state}
  end

  def set_key(pid, %{_: _} = key_value_pair) do
    GenServer.cast(pid, {:add, key_value_pair})
  end

  def get_key(pid) do
    GenServer.call(pid, :get)
  end
end
