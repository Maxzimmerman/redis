defmodule Commands.Handler do
  require Logger

  def handle_connections_async(socket) do
    Commands.Ping.handle_connections_async(socket)
    Commands.Echo.handle_connections_async(socket)
  end
end
