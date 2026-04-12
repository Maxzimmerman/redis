defmodule Commands.Echo do
  @behaviour Commands.Behaviour
  require Logger

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
end
