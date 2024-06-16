defmodule RoguelandiaWeb.GameLive do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.{GameServer, GameManager}
  alias RoguelandiaWeb.Presence

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: player}}} = socket) do
    socket = stream(socket, :presences, [])

    socket =
      if connected?(socket) do
        Presence.track_user(player.name, %{id: player.name})
        Presence.subscribe()

        game_id = 1
        {:ok, pid} = GameManager.find_or_create_game_server(game_id)
        GameServer.add_player(pid, player)

        stream(socket, :presences, Presence.list_online_users())
      else
        socket
      end

    {
      :ok,
      socket
      |> assign(:player, player)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  @impl true
  def handle_info({RoguelandiaWeb.GameLive.ClassSelect, {:class_selected, player_result}}, socket) do
    case player_result do
      {:ok, player} ->
        {:noreply, assign(socket, :player, player)}
      {:error, message, player} ->
        {:noreply,
          socket
          |> assign(:player, player)
          |> put_flash(:error, message)
        }
    end
  end

  def handle_info({RoguelandiaWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({RoguelandiaWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end
end
