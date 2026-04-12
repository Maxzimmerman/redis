defmodule Commands.Ping do
  def handle_connections(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        Task.start(fn -> handle_client(client) end)
        handle_connections(socket)
      {:error, reason} ->
        Logger.error("Error accepting connection: #{reason}")
    end

  end

  @spec handle_client(any()) :: any()
  def handle_client(client) do
    case :gen_tcp.recv(client, 0) do
    ({:ok, _data}) ->
      :gen_tcp.send(client, "+PONG\r\n")
      handle_client(client)
    ({:error, :closed}) ->
      :gen_tcp.close(client)
    end
  end
end
