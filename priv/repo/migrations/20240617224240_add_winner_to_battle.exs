defmodule Roguelandia.Repo.Migrations.AddWinnerToBattle do
  use Ecto.Migration

  def change do
    alter table(:battles) do
      add :winner_id, references(:players, on_delete: :nothing)
      add :turns, {:array, :integer}
    end

    create index(:battles, [:winner_id])
  end
end
