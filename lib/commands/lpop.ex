defmodule Commands.Lpop do
  @behaviour Commands.Behaviour

  require Logger

  alias RedisCache

  @impl true
  def execute(client, message, cache_pid) do
    Logger.info(client: client, message: message, command: "LPOP")

    [key | _rest] = message
  end
end
