defmodule Commands.Ping do
  @behaviour Commands.Behaviour
  require Logger

  def handle_client_async(client, args) do
    IO.puts("Received PING command with args: #{inspect(args)}")
    case :gen_tcp.recv(client, 0) do
      {:ok, _data} ->
        IO.puts("Received PING command with args: #{inspect(args)}")
        :gen_tcp.send(client, "+PONG\r\n")
        handle_client_async(client, args)

      {:error, :closed} ->
        IO.inspect("Erorr")
        :gen_tcp.close(client)
    end
  end
end
