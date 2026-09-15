defmodule Commands.XADD do
  @behaviour Commands.Behaviour

  alias Caches.Types.Stream
  alias RedisCache

  @impl true
  def execute(client, [key, id | fields], cache_pid) do
    # TODO add function on cash to return most recent entry
    #

    prev_id =
      RedisCache.get_most_recent()
      |> Map.keys()
      |> Enum.take(0)

    id_higher_than_prev?(id, prev_id)

    updated_fields =
      fields
      |> Enum.chunk_every(2)
      |> Map.new(fn [k, v] -> {k, v} end)

    stream = %Stream{id: id, fields: updated_fields}

    IO.inspect(stream)

    RedisCache.set(cache_pid, %{key => stream})

    :gen_tcp.send(client, "$#{byte_size(id)}\r\n#{id}\r\n")
  end

  defp id_higher_than_prev?(full_current_id, prev_full_id) do
    current_id = convert_to_id(full_current_id)
    prev_id = convert_to_id(prev_full_id)
    String.to_float(current_id) > String.to_float(prev_id)
  end

  defp construct_id(id) do
    [first, second] = String.split(id, "-")
    "#{System.system_time(:millisecond)}-#{id}"
  end

  defp convert_to_id(full_id) do
    [first, second] = String.split(full_id, "-")
    first
  end
end
