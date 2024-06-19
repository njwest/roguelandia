defmodule RoguelandiaWeb.GameOverLive do
  alias Roguelandia.Game
  use RoguelandiaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:game_over_text, "")
    }
  end

  @impl true
  def handle_params(%{"battle_id" => battle_id}, _, socket) do
    battle = Game.get_battle!(battle_id)

    if is_nil(battle.winner_id) do
      # Game isn't over, redirect to lobbly
      {:noreply, push_navigate(socket, to: ~p"/lobby")}
    else
      {:noreply,
        socket
        |> assign(:game_over_text, battle.game_over_text)
      }
    end
  end
end
