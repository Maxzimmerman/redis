defmodule Commands.Handler do
  require Logger

  alias Commands.Ping
  alias Commands.Echo

  def handle_connections_async(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        Task.start(fn -> handle_client_async(client) end)
      {:error, reason} ->
        Logger.error("Error accepting connection: #{reason}")
    end
    handle_connections_async(socket)
  end

  def handle_client_async(client) do
    {command, args} = encode_data(:gen_tcp.recv(client, 0))

     case command do
      "PING" -> Ping.execute(client, args)
      "ECHO" -> Echo.execute(client, args)
      _ -> Logger.error("Unknown command: #{command}")
    end
  end

  defp encode_data({:ok, data}) do
    parts = String.split(data, "\r\n", trim: true)
    # Filter out RESP prefixes (*N, $N) to get just the values
    args = Enum.reject(parts, fn s -> String.starts_with?(s, "*") or String.starts_with?(s, "$") end)
    command = List.first(args) |> String.upcase()
    {command, Enum.drop(args, 1)}
  end

  defp encode_data({:error, reason}) do
    Logger.error("Error receiving data: #{reason}")
    nil
  end
end
