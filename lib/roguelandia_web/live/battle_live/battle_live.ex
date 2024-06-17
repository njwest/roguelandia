defmodule RoguelandiaWeb.BattleLive do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.{Game, BattleServer, BattleManager}

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: %{player: %{id: player_id}}}} = socket) do
    case Game.find_active_player_battle(player_id) do
      nil ->
        {:ok, push_navigate(socket, to: ~p"/lobby")}
      %{id: battle_id} = _battle ->
        {:ok, pid} = BattleManager.find_or_create_battle_server(battle_id)

        battle = BattleServer.get_state(pid)

        player = Enum.find(battle.participants, fn participant ->
          participant.id == player_id
        end)
        IO.inspect(battle.participants, label: "Participants")

        IO.inspect(player, label: "Player: ")
        other_participants = Enum.filter(battle.participants, fn participant ->
          participant.id != player_id
        end)

        opponent = hd(other_participants)

        {
          :ok,
          socket
          |> assign(:battle_pid, pid)
          |> assign(:battle, battle)
          |> assign(:player, player)
          |> assign(:opponent, opponent)
        }
    end
  end

  # @impl true
  # def handle_params(%{"battle_id" => battle_id}, _, socket) do
  #   socket =
  #     if connected?(socket) do
  #       {:ok, pid} = BattleManager.find_or_create_battle_server(battle_id)

  #       assign(socket, :battle_pid, pid)
  #     else
  #       socket
  #     end

  #   {:noreply, socket}
  # end
end
