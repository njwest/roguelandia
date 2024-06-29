defmodule Roguelandia.NPC.Bot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bots" do
    field :name, :string
    field :level, :integer
    field :special, :string
    field :experience, :integer
    field :hp, :integer
    field :max_hp, :integer
    field :attack, :string
    field :strength, :integer
    field :sprite_url, :string
    field :attitude, Ecto.Enum, values: [:hostile, :friendly, :neutral, :surly, :berzerk]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bot, attrs) do
    bot
    |> cast(attrs, [:name, :level, :experience, :special, :hp, :max_hp, :attack, :strength, :sprite_url, :attitude])
    |> validate_required([:name, :level, :experience, :special, :hp, :max_hp, :attack, :strength, :sprite_url, :attitude])
  end
end
