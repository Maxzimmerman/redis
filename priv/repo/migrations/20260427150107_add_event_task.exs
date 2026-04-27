defmodule Repo.Migrations.AddEventTask do
  use Ecto.Migration

  def change do
    create table(:event_tasks) do
      add :event_type, :string, null: false
      add :payload, :map, null: false
      add :creator, :string, null: false
      add :handler, :string, null: false

      timestamps()
    end
  end
end
