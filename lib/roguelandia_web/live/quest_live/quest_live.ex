defmodule RoguelandiaWeb.QuestLive do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.{Game, NPCServer, NPCManager}

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: %{id: current_player_id}}}} = socket) do
    case Game.find_active_player_battle(current_player_id) do
      %{id: _battle_id} ->
        # Player has a battle, kick them out of the quest
        {
          :ok,
          socket
          |> put_flash(:error, "You must finish your battle before you quest!")
          |> push_navigate(to: ~p"/battle")
        }
      _ ->
        socket =
          if connected?(socket) do
            Phoenix.PubSub.subscribe(Roguelandia.PubSub, "player:#{current_player_id}")
          end

        {:ok, socket}
    end
  end


end
