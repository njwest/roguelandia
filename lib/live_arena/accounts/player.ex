defmodule LiveArena.Accounts.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :level, :integer
    field :special, :string
    field :hp, :integer
    field :strength, :integer
    field :attack, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:level, :hp, :strength, :attack, :special])
    |> validate_required([:level, :hp, :strength, :attack, :special])
  end
end
