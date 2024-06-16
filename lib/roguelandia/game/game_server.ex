defmodule Roguelandia.GameServer do
  use GenServer

  ################################
  ## Client API
  ################################
  def child_spec(game_id) do
    %{
      id: __MODULE__,
      restart: :transient,
      start: {__MODULE__, :start_link, [game_id]}
    }
  end

  def start_link(game_id) do
    process_name = {
      :via,
      Registry,
      {GameRegistry, game_id}
    }

    GenServer.start_link(__MODULE__, game_id, name: process_name)
  end

  def add_player(server, player) do
    GenServer.cast(server, {:add_player, player})
  end

  def handle_presence_diff(server, diff) do
    GenServer.cast(server, {:presence_diff, diff})
  end

  ################################
  ## Server Callbacks
  ################################
  @impl true
  def init(game_id) do
    {:ok,
      %{
        id: game_id,
        description: "The forest is being consumed by a giant blob!",
        boss: %{
          id: 1,
          name: "Giant Blob",
          hp: 50,
          armor: 5,
          attack: %{
            name: "Bite",
            effect: "h-1d6",
          }
        },
        players: []
      }
    }
  end

  @impl true
  def handle_cast({:add_player, player}, state) do
    {:noreply, %{state | players: [player | state.players]}}
  end

  @impl true
  def handle_cast({:presence_diff, diff}, state) do
    new_players = update_players_from_diff(state.players, diff)
    {:noreply, %{state | players: new_players}}
  end

  ################################
  ## Helpers
  ################################
  defp update_players_from_diff(current_players, %{joins: joins, leaves: leaves}) do
    left_players = Map.keys(leaves)

    new_players = current_players
    |> Enum.reject(&(&1.id in left_players))
    |> Enum.concat(for {id, _meta} <- joins, do: %{id: id})

    new_players
  end
end
