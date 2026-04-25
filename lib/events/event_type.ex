defmodule Events.EventType do
  @types [
    element_added: "element_added",
    listen_for_pushed_element: "listen_for_pushed_element"
  ]

  for {name, value} <- @types do
    def unquote(name)(), do: unquote(value)
  end
end
