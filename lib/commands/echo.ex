defmodule Commands.Echo do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, {_, message} = args) do
    Logger.info(client: client, args: args, message: "Received PING command")
    case :gen_tcp.recv(client, 0) do
      {:ok, _data} ->
        :gen_tcp.send(client, "$#{byte_size(message)}\r\n#{message}\r\n")
        execute(client, args)

      {:error, :closed} ->
        :gen_tcp.close(client)

    end
  end
end
