defmodule Roguelandia.GameManager do
  alias Roguelandia.GameServer

  @doc """
  Create a new GameServer process by game_id
  """
  def new_game_server(game_id) do
    case DynamicSupervisor.start_child(GameSupervisor, {GameServer, game_id}) do
      {:ok, pid} -> {:ok, pid}
      otherwise -> {:error, inspect(otherwise)}
    end
  end

  @doc """
  Find a game's `GameServer` by game_id in the `GameRegistry`
  """
  def find_game_server(game_id) do
    case Registry.lookup(GameRegistry, game_id) do
      [] ->
        nil
      [{game_server, nil}] ->
        game_server
    end
  end

  @doc """
  Stop a game server for the given game_id after looking it up in the `GameRegistry`
  """
  def stop_game_server(game_id) do
    game_server = find_game_server(game_id)

    GenServer.stop(game_server)
  end

  @doc """
  List all running game_server servers as a list of tuples of the form `{pid, game_id}`
  """
  def list_game_servers() do
    GameSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} ->  {pid, GameServer.state(pid)} end)
  end

  def find_or_create_game_server(game_id) do
    case find_game_server(game_id) do
      nil ->
        new_game_server(game_id)
      game_server_pid ->
        {:ok, game_server_pid}
    end
  end
end
