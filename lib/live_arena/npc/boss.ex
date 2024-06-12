defmodule LiveArena.NPC.Boss do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bosses" do
    field :name, :string
    field :special, :string
    field :hp, :integer
    field :strength, :integer
    field :attack, :string
    field :avatar_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(boss, attrs) do
    boss
    |> cast(attrs, [:name, :hp, :strength, :attack, :special, :avatar_url])
    |> validate_required([:name, :hp, :strength, :attack, :special, :avatar_url])
  end
end
