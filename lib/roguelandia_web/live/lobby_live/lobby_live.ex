defmodule RoguelandiaWeb.LobbyLive do

  use RoguelandiaWeb, :live_view

  alias RoguelandiaWeb.Presence
  alias Roguelandia.Game

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: player}}} = socket) do
    socket =
      socket
      |> stream(:presences, [])
      |> assign(:player, player)

    socket =
      if connected?(socket) do
        Presence.track_player(player.id, %{id: player.id, name: player.name, level: player.level})
        Presence.subscribe()
        Phoenix.PubSub.subscribe(Roguelandia.PubSub, "player:#{player.id}")

        stream(socket, :presences, Presence.list_online_players())
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  # @impl true
  # def handle_info({RoguelandiaWeb.LobbyLive.ClassSelect, {:class_selected, player_result}}, socket) do
  #   case player_result do
  #     {:ok, player} ->
  #       {:noreply, assign(socket, :player, player)}
  #     {:error, message, player} ->
  #       {:noreply,
  #         socket
  #         |> assign(:player, player)
  #         |> put_flash(:error, message)
  #       }
  #   end
  # end

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

  # def handle_info({:challenge, player_id}, %{player: %{id: player_id}} = socket) do
  #   IO.inspect(player_id)
  #   # Phoenix.PubSub.broadcast(Roguelandia.PubSub, "player:#{player_id}", {:challenge, socket.assigns.player.id})
  #   case Game.find_or_create_empty_player_battle(player_id) do
  #     {:has_battle, battle_id} ->
  #       {:noreply, push_redirect(socket, to: ~p"/battles/#{battle_id}")}
  #     {:ok, battle} ->
  #       IO.inspect(battle)
  #       IO.inspect("Send player challenge")
  #       {:noreply, socket}
  #   end

  #   {:noreply, socket}
  # end

  @impl true
  def handle_event("challenge", %{"player_id" => challenged_player_id}, %{assigns: %{player: %{id: player_id}}} = socket) do
    case Game.find_or_create_empty_player_battle(player_id) do
      {:has_battle, battle_id} ->
        {:noreply, push_redirect(socket, to: ~p"/battles/#{battle_id}")}
      {:ok, battle} ->
        IO.inspect(battle)
        IO.inspect("Send player challenge")
        {:noreply, socket}
    end
  end

  defp stream_length(stream) do
    case Enum.take(@streams.presences, 2) do
      [something] -> IO.inspect("what")
      something_else -> IO.inspect(something_else)
    end
  end
end
