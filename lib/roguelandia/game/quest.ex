defmodule Roguelandia.Game.Quest do
  use Ecto.Schema
  import Ecto.Changeset

  alias Roguelandia.Game.PlayerQuest

  schema "quests" do
    field :name, :string
    field :state, :map

    many_to_many :players, Player, join_through: "player_quest"
    has_many :player_quests, PlayerQuest

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quest, attrs) do
    quest
    |> cast(attrs, [:name, :state])
    |> validate_required([:name])
  end
end
