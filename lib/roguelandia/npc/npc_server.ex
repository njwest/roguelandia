defmodule Roguelandia.NPCServer do
  use GenServer
  alias Roguelandia.{Game, NPC}
  alias RoguelandiaWeb.Endpoint

  def child_spec(bot_id) do
    %{
      id: __MODULE__,
      restart: :transient,
      start: {__MODULE__, :start_link, [bot_id]}
    }
  end

  # Client API

  def start_link(bot_id) do
    process_name = {
      :via,
      Registry,
      {NPCRegistry, bot_id}
    }

    GenServer.start_link(__MODULE__, bot_id, name: process_name)
  end

  @impl true
  def init(bot_id) do
    npc = NPC.get_bot!(bot_id)

    {:ok, npc}
  end
end
