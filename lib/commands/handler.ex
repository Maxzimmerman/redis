defmodule Commands.Handler do
  require Logger

  def handle_connections_async(socket) do
    Commands.Echo.handle_connections_async(socket)
    Commands.Ping.handle_connections_async(socket)
  end
end
