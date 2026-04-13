defmodule Commands.Echo do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message) do
    Logger.info(client: client, message: message)
    case :gen_tcp.recv(client, 0) do
      {:ok, _data} ->
        :gen_tcp.send(client, "$#{byte_size(message)}\r\n#{message}\r\n")
        execute(client, message)

      {:error, :closed} ->
        :gen_tcp.close(client)

    end
  end
end
