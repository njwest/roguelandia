defmodule LiveArena.Pawn.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field :name, :string
    field :hp, :integer
    field :strength, :integer
    field :attack, :string
    field :special, :string
    field :avatar_url, :string
    field :active_limit, :integer
    field :available, :integer, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :hp, :strength, :attack, :special, :avatar_url, :active_limit])
    |> validate_required([:name, :hp, :strength, :attack, :special, :avatar_url, :active_limit])
  end
end
