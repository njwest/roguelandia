defmodule Roguelandia.NPCServer do
  use GenServer
  alias Roguelandia.Game
  alias Roguelandia.BattleServer
  alias RoguelandiaWeb.Endpoint

  def child_spec(battle_id) do
    %{
      id: __MODULE__,
      restart: :transient,
      start: {__MODULE__, :start_link, [battle_id]}
    }
  end

  # Client API

  def start_link(npc_id) do
    process_name = {
      :via,
      Registry,
      {NPCRegistry, npc_id}
    }

    GenServer.start_link(__MODULE__, npc_id, name: process_name)
  end

end
