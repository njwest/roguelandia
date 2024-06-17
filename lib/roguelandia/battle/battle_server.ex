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

  def attack(pid, attacker_id) do
    GenServer.call(pid, {:attack, attacker_id})
  end

  def flee(pid, player_id) do
    GenServer.call(pid, {:flee, player_id})
  end

  def status(pid) do
    GenServer.call(pid, :status)
  end

  def get_state(server) do
    GenServer.call(server, :get_state)
  end

  # Server (callbacks)

  @impl true
  def init(battle_id) do
    state = Game.find_battle_with_participants(battle_id)

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end


  def handle_call({:attack, attacker_id}, _from, state) do
    if state.winner do
      {:reply, {:error, "Battle has ended"}, state}
    else
      current_turn = state.current_turn

      if attacker_id != current_turn do
        {:reply, {:error, "Not your turn"}, state}
      else
        new_state = process_attack(state, attacker_id)
        {:reply, :ok, new_state}
      end
    end
  end


  def handle_call({:flee, player_id}, _from, state) do
    if state.winner do
      {:reply, {:error, "Battle has ended"}, state}
    else
      new_state = process_flee(state, player_id)
      {:reply, :ok, new_state}
    end
  end


  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end

  defp process_attack(state, attacker_id) do
    target_id = Enum.find(state.turn_order, fn id -> id != attacker_id end)

    players = Map.update!(state.players, target_id, fn target ->
      %{target | health: target.health - 10}
    end)

    new_turn_order =
      state.turn_order
      |> List.delete(attacker_id)
      |> List.insert_at(-1, attacker_id)

    next_turn = hd(new_turn_order)

    %{
      state
      | players: players,
        turn_order: new_turn_order,
        current_turn: next_turn,
        winner: check_winner(players)
    }
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

  defp check_winner(players) do
    living_players = Enum.filter(players, fn {_id, player} -> player.health > 0 end)

    case living_players do
      [%{id: id}] -> id
      _ -> nil
    end
  end
end
