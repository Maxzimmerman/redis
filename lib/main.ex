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
        # Parse RESP2 for PING command
        case parse_resp2(data) do
          ["PING"] ->
            :gen_tcp.send(client, "+PONG\r\n")
          _ ->
            :ok
        end
        handle_client(client)
      {:error, :closed} ->
        :ok
      {:error, _reason} ->
        :ok
    end
  end

  # Minimal RESP2 array parser for commands like PING
  defp parse_resp2(<<"*", rest::binary>>) do
    [_count, rest] = String.split(rest, "\r\n", parts: 2)
    parse_resp2_items(rest, [])
  end

  defp parse_resp2_items(<<>>, acc), do: Enum.reverse(acc)
  defp parse_resp2_items(<<"$", rest::binary>>, acc) do
    [len, rest] = String.split(rest, "\r\n", parts: 2)
    {item, rest} = String.split_at(rest, String.to_integer(len))
    rest = String.replace_prefix(rest, "\r\n", "")
    parse_resp2_items(rest, [item | acc])
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
