defmodule Roguelandia.Notify.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  alias Roguelandia.Accounts.User

  schema "notifications" do
    # Entity type is on NotificationType,
    # e.g. Challenge or FriendRequest
    field :entity_id, :integer
    field :entity_type, :string

    field :read_at, :naive_datetime
    belongs_to :actor, User
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:actor_id, :entity_id, :entity_type, :read_at, :user_id, ])
    |> validate_required([:actor_id, :entity_id, :entity_type, :user_id])
  end
end
