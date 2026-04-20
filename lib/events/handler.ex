defmodule Events.Handler do
  alias Events.Event

  @callback handle_event(Event.t()) :: :ok | {:ok, any()} | {:error, any()}
end
