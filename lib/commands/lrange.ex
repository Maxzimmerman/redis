defmodule Commands.LRange do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "LRange")

    [key | [start_index, end_index]] = message

    elements = RedisCache.get_range(cache_pid, key, String.to_integer(start_index), String.to_integer(end_index))

    IO.inspect(elements)

    body = for element <- elements, into: "", do: "$#{byte_size(element)}\r\n#{element}\r\n"
    :gen_tcp.send(client, "*#{length(elements)}\r\n" <> body)
  end
end
