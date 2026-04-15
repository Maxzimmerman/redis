defmodule Commands.Get do
  @behaviour Commands.Behaviour
  require Logger

  def execute(client, message, key_values) do
    Logger.info(client: client, message: message)
    key = List.first(message)
    value = Map.get(key_values, key, nil)

    if value do
      IO.inspect(value, label: "Value found for key #{key}")
      :gen_tcp.send(client, "$#{byte_size(value)}\r\n#{value}\r\n")
    else
      :gen_tcp.send(client, "$-1\r\n")
    end

    key_values
  end
end
