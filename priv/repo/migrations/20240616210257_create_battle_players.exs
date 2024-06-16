defmodule Roguelandia.Repo.Migrations.CreateBattlePlayers do
  use Ecto.Migration

  def change do
    create table(:battle_players) do
      add :battle_id, references(:battles, on_delete: :nothing)
      add :player_id, references(:players, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:battle_players, [:battle_id])
    create index(:battle_players, [:player_id])
  end
end
