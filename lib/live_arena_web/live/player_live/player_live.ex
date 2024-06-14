defmodule LiveArenaWeb.PlayerLive do
  alias LiveArena.Accounts
  use LiveArenaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    changeset = Accounts.change_player(socket.assigns.current_user.player)
    {
      :ok,
      socket
      |> assign(:classes, @classes)
      |> assign(:player, socket.assigns.current_user.player)
      |> assign_form(changeset)
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
