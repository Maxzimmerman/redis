defmodule Events.Event do
  use TypedStruct

  @callback new(any()) :: Events.Event.t()

  typedstruct do
    @derive Jason.Encoder
    field(:type, String.t())
    field(:payload, map())
    field(:metadata, map())
  end
end
