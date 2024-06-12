defmodule LiveArenaWeb.BossLive.Show do
  use LiveArenaWeb, :live_view

  alias LiveArena.NPC

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:boss, NPC.get_boss!(id))}
  end

  defp page_title(:show), do: "Show Boss"
  defp page_title(:edit), do: "Edit Boss"
end
