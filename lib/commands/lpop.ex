defmodule Commands.LPop do
  @behaviour Commands.Behaviour

  require Logger

  alias RedisCache

  @impl true
  def execute(client, [key] = message, cache_pid) do
    Logger.info(client: client, message: message, command: "LPOP")

    case RedisCache.pop_left(key, 1, cache_pid) do
      nil ->
        :gen_tcp.send(client, "$-1\r\n")

      value ->
        :gen_tcp.send(client, "$#{byte_size(value)}\r\n#{value}\r\n")
    end
  end

  def execute(client, [key, count] = message, cache_pid) do
    Logger.info(client: client, message: message, command: "LPOP")

    case RedisCache.pop_left(key, count, cache_pid) do
      nil ->
        :gen_tcp.send(client, "$-1\r\n")

      values ->
        :gen_tcp.send(client, build_response(values))
    end
  end

  defp build_response(elements) do
    body = for element <- elements, into: "", do: "$#{byte_size(element)}\r\n#{element}\r\n"
    "*#{length(elements)}\r\n" <> body
  end
end
