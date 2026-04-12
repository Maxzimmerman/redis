defmodule Commands.Handler do
  require Logger

  @commands %{
    "PING" => Commands.Ping,
    "ECHO" => Commands.Echo
  }

  def handle_connections_async(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        command = find_command(:gen_tcp.recv(client, 0))
        Task.start(fn -> command.handle_client_async(client) end)
        handle_connections_async(socket)

      {:error, reason} ->
        Logger.error("Error accepting connection: #{reason}")
    end
  end

  defp find_command({:ok, data}) do
    Map.get(@commands, String.trim(data))
  end

  defp find_command({:error, reason}) do
    Logger.error("Error receiving data: #{reason}")
    nil
  end
end
