defmodule Roguelandia.Notify do
  @moduledoc """
  The Notify context.

  TODO I wrote this code back in 2020 and have partially refactored; it still needs testing and refactoring, especially around selects.

  Then it needs function documentation.
  """

  import Ecto.Query, warn: false
  # alias Ecto.Multi
  alias Roguelandia.{Repo}

  alias Roguelandia.Notify.{Notification}

  @doc """
  Resolve notification by notification type and entity id.

  ## Examples

    iex> get_unread_notifications(1)
    [%Notification{}, ...]

  """
  def resolve_notifications(entity_type, entity_id) do
    case get_notifications_by_type_entity_id(entity_type, entity_id) do
      [] ->
        {:ok, :nothing_to_resolve}
      notifications ->
        Enum.reduce_while(notifications, {:ok, []}, fn  notification, {:ok, acc} ->
          # resolve every notification
          set_read_at(notification)
          |> case do
            {:ok, notification} ->
              recipient_id_string = Integer.to_string(notification.user_id)

              RoguelandiaWeb.Endpoint.broadcast!(
                "notifications:" <> recipient_id_string,
                "deleteNotif",
                %{
                  notifId: notification.id
                }
              )
              {:cont, [notification | acc]}
            {:error, error} -> {:halt, {:error, error}}
          end
        end)
    end
  end

  def get_notifications_by_type_entity_id(entity_type, entity_id) do
    query =
      from n in Notification,
        where: n.entity_id == ^entity_id and n.entity_type == ^entity_type and is_nil(n.read_at)

    Repo.all(query)
  end

  @doc """
  Get all unread notifications for a user.

  ## Examples

    iex> get_unread_notifications(1)
    [%Notification{}, ...]

  """
  def get_unread_notifications(user_id) do
    query =
      from n in Notification,
      where: n.user_id == ^user_id and is_nil(n.read_at),
      join: a in assoc(n, :actor),
      select: %{
        id: n.id,
        read_at: n.read_at,
        user_id: n.user_id,
        entity_type: n.entity_type,
        inserted_at: n.inserted_at,
        updated_at: n.updated_at,
        actor: %{id: a.id, username: a.username, avatar_url: a.avatar_url}
      }

    Repo.all(query)
  end

  def get_notification_with_content(notification_id) do
    query =
      from n in Notification,
      where: n.id == ^notification_id and not is_nil(n.read_at),
      join: a in assoc(n, :actor),
      select: %{
        id: n.id,
        read_at: n.read_at,
        user_id: n.user_id,
        entity_id: n.entity_id,
        entity_type: n.entity_type,
        inserted_at: n.inserted_at,
        updated_at: n.updated_at,
        actor: %{id: a.id, by_line: a.by_line, username: a.username, avatar_url: a.avatar_url}
      }

    Repo.one(query)
  end

  def get_notifications(user_id) do
    query =
      from n in Notification,
      where: n.user_id == ^user_id and is_nil(n.read_at),
      join: a in assoc(n, :actor),
      select: %{
        id: n.id,
        read_at: n.read_at,
        user_id: n.user_id,
        entity_id: n.entity_id,
        entity_type: n.entity_type,
        inserted_at: n.inserted_at,
        updated_at: n.updated_at,
        actor: %{id: a.id, by_line: a.by_line, username: a.username, avatar_url: a.avatar_url}
      },
      order_by: [desc: :id]

    Repo.all(query)
  end

  def get_unread_notification_count(user_id) do
    query =
      from n in Notification,
      where: n.user_id == ^user_id and is_nil(n.read_at),
      select: fragment("count(*)")

    Repo.one(query)
  end

  def read_notification(notification_id) do
    case get_notification!(notification_id) do
      %{read_at: nil} = notification ->
        set_read_at(notification)
      _ ->
        {:ok, :already_read_or_resolved}
    end
  end

  def resolve_notification(notification_id) do
    case get_notification!(notification_id) do
      %{read_at: read_at} = notification ->
        if is_nil(read_at) do
          set_read_at(notification)
        end
        {:ok, :already_resolved}
      something_unexpected ->
        something_unexpected
    end
  end

  def set_read_at(notification) do
    update_notification(notification, %{read_at: NaiveDateTime.utc_now()})
  end

  # alias Roguelandia.Notify.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    notification_changeset =
      %Notification{}
      |> Notification.changeset(attrs)

    case Repo.insert(notification_changeset) do
      {:ok, notification} ->
        recipient_id_string = Integer.to_string(notification.user_id)

        # TODO implement presence for channels so we only do this query stuff when
        # a user is actually connected to their socket
        full_notification = get_notification_with_content(notification.id)

        unread_count = get_unread_notification_count(notification.user_id)

        # broadcast notification
        RoguelandiaWeb.Endpoint.broadcast!(
          "notifications:" <> recipient_id_string,
          "newNotif",
          %{
            notif: full_notification,
            notificationType: notification.entity_type,
            unreadCount:  unread_count
          }
        )

        {:ok, notification}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
