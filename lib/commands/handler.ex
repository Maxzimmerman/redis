defmodule Commands.Handler do
  require Logger

  @commands %{
    "PING" => Commands.Ping,
    "ECHO" => Commands.Echo
  }

  def handle_connections_async(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        {command, args} = find_command(:gen_tcp.recv(client, 0))
        IO.inspect("Found command $#{comannd} with args #{args}")
        Task.start(fn -> command.handle_client_async(client, args) end)
        handle_connections_async(socket)

      {:error, reason} ->
        Logger.error("Error accepting connection: #{reason}")
    end
  end

  defp find_command({:ok, data}) do
    parts = String.split(data, "\r\n", trim: true)
    # Filter out RESP prefixes (*N, $N) to get just the values
    args = Enum.reject(parts, fn s -> String.starts_with?(s, "*") or String.starts_with?(s, "$") end)
    command = List.first(args) |> String.upcase()
    {Map.get(@commands, command), Enum.drop(args, 1)}
  end

  defp find_command({:error, reason}) do
    Logger.error("Error receiving data: #{reason}")
    nil
  end
end
