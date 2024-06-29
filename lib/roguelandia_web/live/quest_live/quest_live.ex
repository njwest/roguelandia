defmodule RoguelandiaWeb.QuestLive do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.{Game, NPCServer, NPCManager}

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: %{id: current_player_id}}}} = socket) do
    {:ok, socket}
  end
end
