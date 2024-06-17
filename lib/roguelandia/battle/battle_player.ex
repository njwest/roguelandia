defmodule Roguelandia.Game.BattlePlayer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Roguelandia.Pawn.Player
  alias Roguelandia.Game.Battle

  schema "battle_players" do
    belongs_to :battle, Battle
    belongs_to :player, Player

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(battle_player, attrs) do
    battle_player
    |> cast(attrs, [:battle_id, :player_id])
    |> validate_required([])
  end
end
