defmodule Commands.Handler do
  require Logger

  @commands %{
    "PING" => Commands.Ping,
    "ECHO" => Commands.Echo
  }

  def handle_connections_async(socket) do
    for {_command, module} <- @commands do
      Task.start(fn -> module.handle_connections_async(socket) end)
    end
  end
end
