defmodule Commands.XADD do
  @behaviour Commands.Behaviour

  alias Caches.Types.Stream
  alias RedisCache

  @impl true
  def execute(client, [key, id | fields], cache_pid) do
    stream = %Stream{id: id}

    updated_fields =
      fields
      |> Enum.chunk_every(2)
      |> Map.new(fn [k, v] -> %{k => v} end)

    IO.inspect(updated_fields)

    RedisCache.set(cache_pid, %{key => stream})

    :gen_tcp.send(client, "$#{byte_size(id)}\r\n#{id}\r\n")
  end
end
