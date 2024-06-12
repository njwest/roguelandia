defmodule LiveArenaWeb.BossLive.Index do
  use LiveArenaWeb, :live_view

  alias LiveArena.NPC
  alias LiveArena.NPC.Boss

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :bosses, NPC.list_bosses())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Boss")
    |> assign(:boss, NPC.get_boss!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Boss")
    |> assign(:boss, %Boss{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bosses")
    |> assign(:boss, nil)
  end

  @impl true
  def handle_info({LiveArenaWeb.BossLive.FormComponent, {:saved, boss}}, socket) do
    {:noreply, stream_insert(socket, :bosses, boss)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    boss = NPC.get_boss!(id)
    {:ok, _} = NPC.delete_boss(boss)

    {:noreply, stream_delete(socket, :bosses, boss)}
  end
end
