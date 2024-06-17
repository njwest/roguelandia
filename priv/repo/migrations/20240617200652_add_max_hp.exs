defmodule Roguelandia.Repo.Migrations.AddMaxHp do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :max_hp, :integer
    end
  end
end
