defmodule Commands.Handler do
  require Logger

  alias Commands.Ping
  alias Commands.Echo
  alias Commands.Set
  alias Commands.Get
  alias Commands.RPush

  @commands %{
    "PING" => Ping,
    "ECHO" => Echo,
    "SET" => Set,
    "GET" => Get,
    "RPUSH" => RPush
  }

  def handle_connections_async(socket, cache_pid) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        Task.start(fn -> handle_client_async(client, cache_pid) end)

      {:error, reason} ->
        Logger.error("Error accepting connection: #{reason}")
    end

    handle_connections_async(socket, cache_pid)
  end

  def handle_client_async(client, cache_pid) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        {command, message} = encode_data(data)

        with command <- find_command(command) do
          command.execute(client, message, cache_pid)
        end

        handle_client_async(client, cache_pid)

      {:error, :closed} ->
        :gen_tcp.close(client)
    end
  end

  defp find_command(command) do
    Map.get(@commands, command)
  end

  defp encode_data(data) do
    parts = String.split(data, "\r\n", trim: true)
    # Filter out RESP prefixes (*N, $N) to get just the values
    args =
      Enum.reject(parts, fn s -> String.starts_with?(s, "*") or String.starts_with?(s, "$") end)

    command = List.first(args) |> String.upcase()
    {command, Enum.drop(args, 1)}
  end
end
