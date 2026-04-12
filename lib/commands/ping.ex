defmodule Commands.Ping do
  @behaviour Commands.Behaviour
  require Logger

  def handle_client_async(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, _data} ->
        :gen_tcp.send(client, "+PONG\r\n")
        handle_client_async(client)

      {:error, :closed} ->
        :gen_tcp.close(client)
    end
  end
end
