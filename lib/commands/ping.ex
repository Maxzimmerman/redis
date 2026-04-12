defmodule Commands.Ping do
  @behaviour Commands.Behaviour
  require Logger

  @spec handle_client_async(any(), port() | {:"$inet", atom(), any()}, any()) :: :ok
  def handle_client_async(socket, client, args) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info(client: client, args: args, message: "Received ECHO command")
    case :gen_tcp.recv(client, 0) do
      {:ok, _data} ->
        :gen_tcp.send(client, "+PONG\r\n")
        handle_client_async(socket, client, args)

      {:error, :closed} ->
        :gen_tcp.close(client)

    end
  end
end
