defmodule Server do
  @moduledoc """
  Your implementation of a Redis server
  """

  use Application

  alias Commands.Handler

  def start(_type, _args) do
    children = [
      {Repo, []},
      {Task, fn -> Server.listen() end}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  Listen for incoming connections
  """
  def listen() do
    {:ok, socket} = :gen_tcp.listen(6379, [:binary, active: false, reuseaddr: true])

    {:ok, cache_pid} = RedisCache.start_link()
    Handler.handle_connections_async(socket, cache_pid)
  end
end

defmodule CLI do
  def main(_args) do
    # Start the Server application
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_redis)

    # Run forever
    Process.sleep(:infinity)
  end
end
