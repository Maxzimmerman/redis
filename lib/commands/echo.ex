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

  def execute(client, args) do
    Logger.error(client: client, args: args, message: "Invalid ECHO command format")
    :gen_tcp.send(client, "-ERR wrong number of arguments for 'ECHO' command\r\n")
    execute(client, args)
  end
end
