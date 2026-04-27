defmodule EventTask do
  use Ecto.Schema

  import Ecto.Changeset

  schema "event_tasks" do
    field :event_type, :string
    field :payload, :map
    field :creator, :string
    field :handler, :string

    timestamps()
  end

  @required_fields ~w(event_type payload creator handler)a

  def changeset(event_task, params \\ %{}) do
    event_task
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
