defmodule Commands.LPop do
  @behaviour Commands.Behaviour

  require Logger

  alias RedisCache

  @impl true
  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "LPOP")

    IO.inspect("Executing LPOP command with message: #{inspect(message)}")

    [key | count] = message
    
    if count > 1 do
      
    end

    case RedisCache.pop_list_element(key, cache_pid) do
      nil ->
        :gen_tcp.send(client, "$-1\r\n")

      value ->
        :gen_tcp.send(client, "$#{byte_size(value)}\r\n#{value}\r\n")
    end
  end
end
