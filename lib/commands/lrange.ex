defmodule Commands.LRange do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "LRange")

    [key | [start_index, end_index]] = message

    elements = RedisCache.get_range(cache_pid, key, String.to_integer(start_index), String.to_integer(end_index))

    IO.inspect(elements)

    for element <- elements do
      :gen_tcp.send(client, "$#{byte_size(element)}\r\n#{element}\r\n")
    end
  end
end
