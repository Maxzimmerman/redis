defmodule Events.EventDispatcher do
  import Events.EventType

  alias Commands.BLPop

  @command_handlers %{
    element_added() => [
      BLPop,
    ]
  }

  def dispatch(event) do
    handlers = Map.get(@command_handlers, event.type, [])

    try do
      Enum.reduce_while(handlers, {:ok, event}, fn handler, _acc ->

        case handler.handle_event(event) do
          :ok -> {:cont, {:ok, nil}}
          {:ok, result} -> {:cont, {:ok, result}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    rescue
      e ->
        {:error, e}
    end
  end
end
