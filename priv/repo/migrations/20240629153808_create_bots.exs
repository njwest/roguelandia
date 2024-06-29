defmodule Roguelandia.Repo.Migrations.CreateBots do
  use Ecto.Migration

  def change do
    create table(:bots) do
      add :name, :string
      add :level, :integer
      add :experience, :integer
      add :special, :string
      add :hp, :integer
      add :max_hp, :integer
      add :attack, :string
      add :strength, :integer
      add :sprite_url, :string
      add :attitude, :string

      timestamps(type: :utc_datetime)
    end
  end
end
