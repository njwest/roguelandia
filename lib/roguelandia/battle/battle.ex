defmodule Roguelandia.Game.Battle do
  use Ecto.Schema
  import Ecto.Changeset

  alias Roguelandia.Game.BattlePlayer
  alias Roguelandia.Pawn.Player

  schema "battles" do
    field :active, :boolean
    field :turns, {:array, :integer}
    field :game_over_text, :string
    belongs_to :creator, Player, foreign_key: :creator_id
    belongs_to :winner, Player, foreign_key: :winner_id

    many_to_many :participants, Player, join_through: "battle_players"
    has_many :battle_players, BattlePlayer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(battle, attrs) do
    battle
    |> cast(attrs, [:creator_id, :winner_id, :active, :turns, :game_over_text])
    |> validate_required([:creator_id])
  end
end
