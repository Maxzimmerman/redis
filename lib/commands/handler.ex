defmodule Commands.Handler do
  require Logger

  def handle_connections_async(socket) do
    Task.start(fn -> Commands.Echo.handle_connections_async(socket) end)
    Task.start(fn -> Commands.Ping.handle_connections_async(socket) end)
  end
end
