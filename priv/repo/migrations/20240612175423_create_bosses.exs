defmodule LiveArena.Repo.Migrations.CreateBosses do
  use Ecto.Migration

  def change do
    create table(:bosses) do
      add :name, :string
      add :hp, :integer
      add :strength, :integer
      add :attack, :string
      add :special, :string
      add :avatar_url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
