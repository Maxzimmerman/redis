defmodule Events.EventType do
  @types [
    element_added: "element_added"
  ]

  for {name, value} <- @types do
    def unquote(name)(), do: unquote(value)
  end
end
