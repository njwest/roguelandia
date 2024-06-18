defmodule RoguelandiaWeb.BattleLive do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.{Game, BattleServer, BattleManager}

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: %{id: current_player_id}}}} = socket) do
    case Game.find_active_player_battle(current_player_id) do
      nil ->
        {:ok, push_navigate(socket, to: ~p"/lobby")}
      %{id: battle_id} = _battle ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(Roguelandia.PubSub, "battle:#{battle_id}")
        end

        {:ok, pid} = BattleManager.find_or_create_battle_server(battle_id)

        battle = BattleServer.get_state(pid)

        {
          :ok,
          socket
          |> assign(:battle_pid, pid)
          |> assign(:action_text, "")
          |> assign_battle(battle, current_player_id)
        }
    end
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "battle:" <> _battle_id, event: "battle_updated", payload: {battle, action}}, %{assigns: %{player: %{id: current_player_id}}} = socket) do
    # TODO this is sloppy, change the system for action messages
    # both here and in the BattleServer

    action_text =
      case action.type do
        :attack ->
          cond do
            action.actor_id == current_player_id ->
              "You #{action.message}"
            true ->
              "You were #{action.message}"
          end
        :flee ->
          cond do
            action.actor_id == current_player_id ->
              "You #{action.message}"
            true ->
              "#{socket.assigns.opponent.name} #{action.message}"
          end
      end

    {
      :noreply,
      socket
      |> assign(:action_text, action_text)
      |> assign_battle(battle, current_player_id)
    }
  end

  @impl true
  def handle_event("attack", _, %{assigns: %{ player: player, opponent: opponent, battle_pid: pid}} = socket) do
    BattleServer.attack(pid, player.id,  opponent.id)

    {:noreply, assign(socket, :action_text, "You #{player.attack} at #{opponent.name}...")}
  end

  def handle_event("flee", _, %{assigns: %{ player: %{id: player_id}, opponent: opponent, battle_pid: pid}} = socket) do
    BattleServer.flee(pid, player_id)

    {:noreply, assign(socket, :action_message, "You attempt to flee from #{opponent.name}...")}
  end

  defp assign_battle(socket, battle, current_player_id) do
    if is_nil(battle.winner_id) do
      player = Game.find_participant(battle, current_player_id)

      other_participants = Enum.filter(battle.participants, fn participant ->
        participant.id != current_player_id
      end)

      socket
      |> assign(:player, player)
      |> assign(:opponent, hd(other_participants))
      |> assign(:current_turn_player_id, hd(battle.turns))
    else
      push_navigate(socket, to: ~p"/battles/#{battle.id}")
    end

  end
end
