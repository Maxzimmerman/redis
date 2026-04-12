defmodule Commands.Echo do

  require Logger

  def handle_connections(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
      Task.start(fn -> handle_client(client) end)
      handle_connections(socket)
    {:error, _} -> Logger.error("Error accepting connection")
    end
  end

  def handle_client(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        :gen_tcp.send(client, "+#{data}\r\n")
        handle_client(client)
      {:error, :closed} -> :gen_tcp.close(client)
       _ -> Logger.error("Error receiving data")
      end
    end
end
