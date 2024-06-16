defmodule Roguelandia.Repo.Migrations.CreateBattles do
  use Ecto.Migration

  def change do
    create table(:battles) do
      add :active, :boolean, default: false
      add :creator_id, references(:players, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:battles, [:creator_id])
  end
end
