defmodule LiveArena.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :name, :string
      add :hp, :integer
      add :strength, :integer
      add :attack, :string
      add :special, :string
      add :avatar_url, :string
      add :active_limit, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
