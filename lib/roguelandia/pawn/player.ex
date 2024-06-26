defmodule Roguelandia.Pawn.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Roguelandia.Accounts.User
  alias Roguelandia.Pawn.Class
  alias Roguelandia.Game.BattlePlayer

  schema "players" do
    field :name, :string
    field :level, :integer
    field :experience, :integer
    field :special, :string
    field :hp, :integer
    field :max_hp, :integer
    field :strength, :integer
    field :attack, :string
    field :avatar_url, :string
    belongs_to :user, User
    belongs_to :class, Class
    has_many :battle_players, BattlePlayer
    has_many :battles, through: [:battle_players, :battle]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:user_id, :class_id, :name, :level, :experience, :hp, :max_hp, :strength, :attack, :special, :avatar_url])
    |> validate_required([:user_id, :name])
    |> unique_constraint(:name)
  end
end
