defmodule Roguelandia.BattleServer do

  use GenServer
  alias Roguelandia.Game
  alias RoguelandiaWeb.Endpoint

  def child_spec(battle_id) do
    %{
      id: __MODULE__,
      restart: :transient,
      start: {__MODULE__, :start_link, [battle_id]}
    }
  end

  # Client API

  def start_link(battle_id) do
    process_name = {
      :via,
      Registry,
      {BattleRegistry, battle_id}
    }

    GenServer.start_link(__MODULE__, battle_id, name: process_name)
  end

  def get_memory_usage(pid) do
    :erlang.process_info(pid, :memory)
  end

  def attack(pid, attacker_id, target_id) do
    GenServer.cast(pid, {:attack, attacker_id, target_id})
  end

  def flee(pid, player_id) do
    GenServer.cast(pid, {:flee, player_id})
  end

  def get_state(server) do
    GenServer.call(server, :get_state)
  end

  # Server (callbacks)

  @impl true
  def init(battle_id) do
    battle = Game.find_battle_with_participants(battle_id)

    {:ok, battle}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:flee, player_id}, _from, state) do
    if state.winner do
      {:reply, {:error, "Battle has ended"}, state}
    else
      new_state = process_flee(state, player_id)
      {:reply, :ok, new_state}
    end
  end

  @impl true
  def handle_cast({:attack, attacker_id, target_id}, state) do
    if state.winner_id do
      # TODO battle has ended broadcast
      {:noreply, state}
    else
      current_turn_player_id = hd(state.turns)

      if attacker_id != current_turn_player_id do
        # TODO not your turn broadcast
        {:noreply, state}
      else
        case Game.process_attack(state, attacker_id, target_id) do
          {:ok, attack_result} ->
            new_state = Game.find_battle_with_participants(state.id)

            action_message = %{actor_id: attacker_id, message: attack_action_text(attack_result)}

            Endpoint.broadcast("battle:#{new_state.id}", "battle_updated", {new_state, action_message})

            {:noreply, new_state}
          {:error, _message} ->
            # TODO broadcast error
            {:noreply, state}
        end

      end
    end
  end

  # TODO handle this on the UI rather than in the server
  # for easier insertion of target name
  defp attack_action_text(attack_result) do
    case attack_result do
      {:hit, damage} ->
        "hit for #{damage} damage!"
      {:miss, _} ->
        "missed!"
    end
  end

  defp check_winner(players) do
    living_players = Enum.filter(players, fn {_id, player} -> player.health > 0 end)

    case living_players do
      [%{id: id}] -> id
      _ -> nil
    end
  end

  def handle_cast({:flee, player_id}, state) do
    if state.winner do
      # broadcast
      {:noreply, state}
    else
      current_turn_player_id = hd(state.turns)

      if player_id != current_turn_player_id do
        # broadcast
        {:noreply, state}
      else
        # new_state = process_flight(state, player_id)

        {:noreply, state}
      end
    end
  end

  defp process_flee(state, player_id) do
    players = Map.delete(state.players, player_id)
    new_turn_order = List.delete(state.turn_order, player_id)
    next_turn = hd(new_turn_order)
    new_winner = check_winner(players)

    %{
      state
      | players: players,
        turn_order: new_turn_order,
        current_turn: next_turn,
        winner: new_winner
    }
  end
end
