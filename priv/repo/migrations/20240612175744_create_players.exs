defmodule LiveArena.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :level, :integer
      add :hp, :integer
      add :strength, :integer
      add :attack, :string
      add :special, :string

      timestamps(type: :utc_datetime)
    end
  end
end
