defmodule Events.Index do
  import Ecto.Query

  def insert_task(changeset) do
    Repo.insert(changeset)
  end

  def delete_taks(task_id) do
    from(et in EventTask, where: et.id == ^task_id)
    |> Repo.delete_all()
  end
end
