defmodule LiveArena.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :citext, null: false
      add :level, :integer
      add :experience, :integer
      add :hp, :integer
      add :strength, :integer
      add :attack, :string
      add :special, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:players, [:user_id])
  end
end
