defmodule Roguelandia.Game.Battle do
  use Ecto.Schema
  import Ecto.Changeset

  alias Roguelandia.Game.BattlePlayer
  alias Roguelandia.Pawn.Player

  schema "battles" do
    belongs_to :creator, Player, foreign_key: :creator_id
    many_to_many :participants, Player, join_through: "battle_players"
    has_many :battle_players, BattlePlayer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(battle, attrs) do
    battle
    |> cast(attrs, [:creator_id])
    |> validate_required([:creator_id])
  end
end
