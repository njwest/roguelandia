defmodule RoguelandiaWeb.GameLive do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.{GameServer, GameManager}

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: player}}} = socket) do
    {
      :ok,
      socket
      |> assign(:player, player)
    }
  end

  @impl true
  def handle_params(%{"game_id" => game_id}, _, socket) do
    socket =
      if connected?(socket) do
        {:ok, pid} = GameManager.find_or_create_game_server(game_id)
        GameServer.add_player(pid, socket.assigns.player)
      else
        socket
      end

    {:noreply, socket}
  end
end
