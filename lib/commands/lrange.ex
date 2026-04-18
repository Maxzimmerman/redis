defmodule Commands.LRange do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "LRange")

    [key | [start_index, end_index]] = message
    length = RedisCache.get_length(cache_pid, key)
    start_index = build_index(String.to_integer(start_index), length)
    end_index = build_index(String.to_integer(end_index), length)

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

  defp build_index(index, length) do
    new_index =
      case index do
        i when i < 0 -> length + index
        i when i >= 0 -> i
      end

    if new_index < 0 do
      0
    else
      new_index
    end
  end

  defp build_response(elements) do
    body = for element <- elements, into: "", do: "$#{byte_size(element)}\r\n#{element}\r\n"
    "*#{length(elements)}\r\n" <> body
  end
end
