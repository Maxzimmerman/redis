defmodule Commands.XADD do
  @behaviour Commands.Behaviour

  alias Caches.Types.Stream
  alias RedisCache

  @impl true
  def execute(client, [key, id | fields], cache_pid) do
    stream = %Stream{id: id}

    RedisCache.set(cache_pid, %{key => stream})

    :gen_tcp.send(client, "$#{byte_size(id)}\r\n#{id}\r\n")
  end
end
