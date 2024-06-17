defmodule RoguelandiaWeb.LobbyLive do

  alias RoguelandiaWeb.Endpoint

  use RoguelandiaWeb, :live_view

  alias RoguelandiaWeb.Presence
  alias Roguelandia.Game

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: player}}} = socket) do
    socket =
      socket
      |> stream(:presences, [])
      |> assign(:player, player)
      |> assign(:challenge, nil)

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

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "player:" <> _player_id, event: "challenge", payload: challenge_payload}, socket) do
    {:noreply, assign(socket, :challenge, challenge_payload)}
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

  @impl true
  def handle_event("challenge", %{"player_id" => challenged_player_id}, %{assigns: %{player: %{id: challenger_id, name: challenger_name, level: challenger_level}}} = socket) do
    case Game.find_or_create_empty_player_battle(challenger_id) do
      {:has_battle, battle_id} ->
        {:noreply, push_redirect(socket, to: ~p"/battles/#{battle_id}")}
      {:ok, battle} ->

        IO.inspect("Send player challenge")
        challenge_payload = %{challenger_id: challenger_id, challenger_name: challenger_name, challenger_level: challenger_level, battle_id: battle.id}

        Endpoint.broadcast("player:#{challenged_player_id}", "challenge", challenge_payload)

        {:noreply, assign(socket, :pending_battle_id, battle.id)}
    end
  end

  def handle_event("accept", %{"battle_id" => battle_id}, socket) do
    case Game.accept_player_battle(String.to_integer(battle_id), socket.assigns.player.id) do
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
      {:ok, battle} ->
        {:noreply, push_redirect(socket, to: ~p"/battles/#{battle.id}")}
    end
  end

  def handle_event("decline", %{"battle_id" => _battle_id}, socket) do
    {:noreply, assign(socket, :challenge, nil)}
  end
end
