defmodule Commands.LRange do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "LRange")

    [key | [start_index, end_index]] = message
    start_index = String.to_integer(start_index)
    end_index = String.to_integer(end_index)
    length = RedisCache.get_length(cache_pid, key)

    if start_index < 0 and end_index < 0 do
      start_index = length - start_index * -1
      end_index = length - end_index * -1

      case RedisCache.get_range(
             cache_pid,
             key,
             start_index,
             end_index
           ) do
        nil -> :gen_tcp.send(client, "*0\r\n")
        elements when is_list(elements) -> :gen_tcp.send(client, build_response(elements))
      end
    end
  end

  defp build_response(elements) do
    body = for element <- elements, into: "", do: "$#{byte_size(element)}\r\n#{element}\r\n"
    "*#{length(elements)}\r\n" <> body
  end
end
