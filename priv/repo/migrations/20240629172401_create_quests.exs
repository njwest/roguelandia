defmodule Roguelandia.Repo.Migrations.CreateQuests do
  use Ecto.Migration

  def change do
    create table(:quests) do
      add :name, :string
      add :state, :map

      timestamps(type: :utc_datetime)
    end
  end
end
