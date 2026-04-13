defmodule Commands.Handler do
  require Logger

  def handle_connections_async(socket) do
    Task.async(fn -> Commands.Echo.handle_connections_async(socket) end)
    Task.async(fn -> Commands.Ping.handle_connections_async(socket) end)
  end
end
