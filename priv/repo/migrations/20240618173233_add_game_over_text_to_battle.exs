defmodule Roguelandia.Repo.Migrations.AddGameOverTextToBattle do
  use Ecto.Migration

  def change do
    alter table(:battles) do
      add :game_over_text, :string
    end
  end
end
