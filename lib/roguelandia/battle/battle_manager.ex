defmodule Roguelandia.BattleManager do
  require Logger
  alias Roguelandia.BattleServer

  @doc """
  Create a new BattleServer process by battle_id
  """
  def new_battle_server(battle_id) do
    case DynamicSupervisor.start_child(BattleSupervisor, {BattleServer, battle_id}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} ->
        Logger.error("new_battle_server()/1: BattleServer already started with pid: #{inspect(pid)}.")

        {:ok, pid}
      {:error, result} -> {:error, result}
      otherwise -> {:error, inspect(otherwise)}
    end
  end

  @doc """
  Find a battle's `BattleServer` by battle_id in the `BattleRegistry`
  """
  def find_battle_server(battle_id) do
    case Registry.lookup(BattleRegistry, battle_id) do
      [] ->
        nil
      [{battle_server, nil}] ->
        battle_server
    end
  end

  @doc """
  Stop a battle server for the given battle_id after looking it up in the `BattleRegistry`
  """
  def stop_battle_server(battle_id) do
    battle_server = find_battle_server(battle_id)

    GenServer.stop(battle_server)
  end

  @doc """
  List all running battle_server servers as a list of tuples of the form `{pid, battle_id}`
  """
  def list_battle_servers() do
    BattleSupervisor
    |> DynamicSupervisor.which_children()
    # |> Enum.map(fn {_, pid, _, _} ->  {pid, BattleServer.get_state(pid)} end)
  end

  def find_or_create_battle_server(battle_id) do
    case find_battle_server(battle_id) do
      nil ->
        new_battle_server(battle_id)
      battle_server_pid ->
        {:ok, battle_server_pid}
    end
  end
end
