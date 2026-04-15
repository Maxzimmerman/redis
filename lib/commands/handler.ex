defmodule Commands.Handler do
  require Logger

  alias Commands.Ping
  alias Commands.Echo
  alias Commands.Set

  def handle_connections_async(socket, key_values) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        Task.start(fn -> handle_client_async(client, key_values) end)
      {:error, reason} ->
        Logger.error("Error accepting connection: #{reason}")
    end
    handle_connections_async(socket, key_values)
  end

  def handle_client_async(client, key_values) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        {command, message} = encode_data(data)

        case command do
          "PING" -> Ping.execute(client, message, key_values)
          "ECHO" -> Echo.execute(client, message, key_values)
          "SET" -> Set.execute(client, message, key_values)
          _ -> Logger.error("Unknown command: #{command}")
        end

        handle_client_async(client, key_values)

      {:error, :closed} ->
        :gen_tcp.close(client)
    end
  end

  defp encode_data(data) do
    parts = String.split(data, "\r\n", trim: true)
    # Filter out RESP prefixes (*N, $N) to get just the values
    args = Enum.reject(parts, fn s -> String.starts_with?(s, "*") or String.starts_with?(s, "$") end)
    command = List.first(args) |> String.upcase()
    {command, Enum.drop(args, 1)}
  end
end
