defmodule Roguelandia.Game.PlayerQuest do
  use Ecto.Schema
  import Ecto.Changeset

  alias Roguelandia.Pawn.Player
  alias Roguelandia.Game.Quest

  schema "player_quests" do
    field :state, :map
    field :active?, :boolean, default: true
    belongs_to :player, Player
    belongs_to :quest, Quest


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player_quest, attrs) do
    player_quest
    |> cast(attrs, [:player_id, :quest_id, :state, :active?])
    |> validate_required([:player_id, :quest_id, :state])
  end
end
