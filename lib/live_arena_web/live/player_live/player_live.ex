defmodule LiveArenaWeb.PlayerLive do
  use LiveArenaWeb, :live_view

  @classes [
    %{"name" => "Warrior", "hp" => 50, "strength" => 8, "attack" => "Slash", "avatar_url" => "/images/rogue-warrior.png"},
    %{"name" => "Archer", "hp" => 55, "strength" => 6, "attack" => "Shoot", "avatar_url" => "/images/rogue-archer.png"},
    %{"name" => "Cleric", "hp" => 60, "strength" => 5, "attack" => "Bash", "avatar_url" => "/images/rogue-cleric.png"},
    %{"name" => "Robot", "hp" => 45, "strength" => 10, "attack" => "Bash", "avatar_url" => "/images/rogue-robot.png"}
]

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:classes, @classes)
      |> assign(:player, socket.assigns.current_user.player)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Home")
  end

  # @impl true
  # def handle_info({LiveArenaWeb.BossLive.FormComponent, {:saved, boss}}, socket) do
  #   {:noreply, stream_insert(socket, :bosses, boss)}
  # end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   boss = NPC.get_boss!(id)
  #   {:ok, _} = NPC.delete_boss(boss)

  #   {:noreply, stream_delete(socket, :bosses, boss)}
  # end
end
