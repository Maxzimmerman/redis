defmodule Commands.Type do
  @behaviour Commands.Behaviour

  require Logger

  alias RedisCache

  def execute(client, [_command, key] = message, cache_pid) do
    Logger.info(client: client, message: message)
    case RedisCache.get(cache_pid, key) do
      nil ->
        :gen_tcp.send(client, "$-1\r\n")
      element ->
        send_response(element, client)
    end
  end

  def execute(client, message, cache_pid) do
    IO.inspect(message)
  end

  defp send_response(element, client) when is_binary(element), do: :gen_tcp.send(client, "$#{byte_size(element)}\r\n#{element}\r\n")
end
