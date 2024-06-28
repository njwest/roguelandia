defmodule Roguelandia.Repo.Migrations.UniquePlayerNames do
  use Ecto.Migration

  def change do
    create unique_index(:players, [:name])
  end
end
