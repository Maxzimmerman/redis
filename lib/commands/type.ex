defmodule Commands.Type do
  @behaviour Commands.Behaviour

  require Logger

  alias RedisCache
  alias Caches.Types.Stream

  def execute(client, [key], cache_pid) do
    Logger.info(client: client, message: key)
    case RedisCache.get(cache_pid, key) do
      nil ->
        :gen_tcp.send(client, "+none\r\n")
      element ->
        send_response(element, client)
    end
  end

  defp send_response(element, client) when is_binary(element), do: :gen_tcp.send(client, "+string\r\n")
  defp send_response(element, client) when is_list(element), do: :gen_tcp.send(client, "+list\r\n")
  defp send_response(%Stream{}, client), do: :gen_tcp.send(client, "+stream\r\n")
end
