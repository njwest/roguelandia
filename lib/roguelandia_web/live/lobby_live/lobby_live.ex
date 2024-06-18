defmodule RoguelandiaWeb.LobbyLive do

  use RoguelandiaWeb, :live_view

  alias RoguelandiaWeb.Endpoint
  alias RoguelandiaWeb.Presence
  alias Roguelandia.Game

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: player}}} = socket) do
    socket =
      socket
      |> stream(:presences, [])
      |> assign(:player, player)
      |> assign(:challenge, nil)

    case Game.find_active_player_battle(player.id) do
      %{id: _battle_id} ->
        # Player has a battle, kick them out of the lobby
        {:ok, push_navigate(socket, to: ~p"/battle")}
      _ ->
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
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "player:" <> _player_id, event: "challenge", payload: challenge_payload}, socket) do
    if is_nil(socket.assigns.challenge) do
      {:noreply, assign(socket, :challenge, challenge_payload)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: "player:" <> _player_id, event: "commence_battle", payload: _battle}, socket) do
    {:noreply, push_redirect(socket, to: ~p"/battle")}
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
      {:has_battle, _battle_id} ->
        {:noreply, push_redirect(socket, to: ~p"/battle")}
      {:ok, battle} ->
        # TODO MAYBE would be nice to persist challenges in DB
        # to make them more interactive etc
        challenge_payload = %{challenger_id: challenger_id, challenger_name: challenger_name, challenger_level: challenger_level, battle_id: battle.id}

        Endpoint.broadcast("player:#{challenged_player_id}", "challenge", challenge_payload)

        {:noreply, assign(socket, :pending_battle_id, battle.id)}
    end
  end

  def handle_event("accept", _, %{assigns: %{challenge: challenge}} = socket) do
    case Game.accept_player_challenge(challenge, socket.assigns.player.id) do
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
      {:ok, _battle} ->
        {:noreply, push_redirect(socket, to: ~p"/battle")}
    end
  end

  def handle_event("decline", _, socket) do
    {:noreply, assign(socket, :challenge, nil)}
  end
end
