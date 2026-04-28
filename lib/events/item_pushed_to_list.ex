defmodule Events.ItemPushedToList do
  @behaviour Events.Event

  alias Events.Event
  alias Events.EventType, as: EventTypes

  use TypedStruct

  typedstruct module: Payload do
    @derive Jason.Encoder
    field(:list_key, String.t())
    field(:element, String.t())
    field(:cache_pid, pid())
    field(:client, :gen_tcp.socket())
  end

  @impl true
  def new(%Payload{} = payload) do
    %Event{
      type: EventTypes.element_added(),
      payload: payload,
      metadata: %{}
    }
  end
end
