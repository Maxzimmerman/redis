defmodule Server do
  @moduledoc """
  Your implementation of a Redis server
  """

  use Application

  def start(_type, _args) do
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  @doc """
  Listen for incoming connections
  """
  def listen() do
    IO.puts("Logs from your program will appear here!")
    {:ok, socket} = :gen_tcp.listen(6379, [:binary, active: false, reuseaddr: true])
    {:ok, client} = :gen_tcp.accept(socket)
    handle_client(client)
  end

  def handle_client(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        # Respond to PING command
        if String.trim(data) == "*1\r\n$4\r\nPING\r\n" do
          :gen_tcp.send(client, "+PONG\r\n")
        end
        handle_client(client)
      {:error, :closed} ->
        :ok
      {:error, _reason} ->
        :ok
    end
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
