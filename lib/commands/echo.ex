defmodule Commands.Echo do
  @behaviour Commands.Behaviour
  require Logger

  def handle_client_async(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        IO.inspect("Received data: #{data}")
        :gen_tcp.send(client, "+#{data}\r\n")
        handle_client_async(client)
      {:error, :closed} -> :gen_tcp.close(client)
       _ -> Logger.error("Error receiving data")
      end
    end
end
