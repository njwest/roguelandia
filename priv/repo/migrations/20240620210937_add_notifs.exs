defmodule Roguelandia.Repo.Migrations.NotifTypesAndNotifs do
  use Ecto.Migration

  def change() do
    create table(:notifications) do
      add :actor_id, :integer
      add :entity_id, :integer
      add :entity_type, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :read_at, :naive_datetime

      timestamps()
    end

    create index(:notifications, [:user_id])
  end
end
