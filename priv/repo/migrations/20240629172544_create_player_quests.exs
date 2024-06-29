defmodule Roguelandia.Repo.Migrations.CreatePlayerQuests do
  use Ecto.Migration

  def change do
    create table(:player_quests) do
      add :state, :map
      add :player_id, references(:players, on_delete: :nothing)
      add :quest_id, references(:quests, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:player_quests, [:player_id])
    create index(:player_quests, [:quest_id])
  end
end
