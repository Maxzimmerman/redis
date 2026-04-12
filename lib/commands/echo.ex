defmodule Commands.Echo do
  @behaviour Commands.Behaviour
  require Logger

  def handle_connections_async(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        {command, args} = encode_data(:gen_tcp.recv(client, 0))
        if command == "ECHO" do
          Logger.info(client: client, args: args, message: "Received ECHO command")
          Task.start(fn -> handle_client_async(client, args) end)
        end

      {:error, reason} ->
        Logger.error("Error accepting connection: #{reason}")
    end
  end

  def handle_client_async(client, args) do
    Logger.info(client: client, args: args, message: "Received ECHO command")
    message = List.first(args)
    :gen_tcp.send(client, "$#{byte_size(message)}\r\n#{message}\r\n")

    case :gen_tcp.recv(client, 0) do
      {:ok, _data} ->
        handle_client_async(client, args)
      {:error, :closed} -> :gen_tcp.close(client)
       _ -> Logger.error("Error receiving data")
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
