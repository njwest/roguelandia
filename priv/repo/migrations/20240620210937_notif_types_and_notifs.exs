defmodule Roguelandia.Repo.Migrations.NotifTypesAndNotifs do
  use Ecto.Migration

  def change do
    create table(:notification_types) do
      add :type, :string
      add :content, :string

      timestamps()
    end

    create table(:notifications) do
      add :actor_id, :integer
      add :entity_id, :integer
      add :status, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :notification_type_id, references(:notification_types, on_delete: :nothing)

      timestamps()
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:notification_type_id])
  end
end
