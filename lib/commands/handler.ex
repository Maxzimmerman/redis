defmodule Commands.Handler do
  require Logger

  @commands %{
    "PING" => Commands.Ping,
    "ECHO" => Commands.Echo
  }

  def handle_connections_async(socket) do
    Commands.Ping.handle_connections_async(socket)
    Commands.Echo.handle_connections_async(socket)
  end
end
