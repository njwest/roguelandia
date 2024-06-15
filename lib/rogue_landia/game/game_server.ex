defmodule Roguelandia.GameServer do
  use GenServer

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

  @impl true
  def init(_game_id) do
    {:ok,
      %{
      id: 1,
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
        }
      },
      players: []
    }
  end

  @impl true
  def handle_call({:enter, _player}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def enter(server, player) do
    GenServer.call(server, {:enter, player})
  end

  def state(server) do
    GenServer.call(server, :state)
  end

end
