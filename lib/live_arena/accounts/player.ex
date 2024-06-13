defmodule LiveArena.Accounts.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiveArena.Accounts.User

  schema "players" do
    field :name, :string
    field :level, :integer
    field :experience, :integer
    field :special, :string
    field :hp, :integer
    field :strength, :integer
    field :attack, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:user_id, :name, :level, :experience, :hp, :strength, :attack, :special])
    |> validate_required([:user_id, :name])
    |> unique_constraint(:name)
  end
end
