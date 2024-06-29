defmodule RoguelandiaWeb.QuestLive.Index do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.Game
  alias Roguelandia.Game.Quest

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :quests, Game.list_quests())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Quest")
    |> assign(:quest, Game.get_quest!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Quest")
    |> assign(:quest, %Quest{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Quests")
    |> assign(:quest, nil)
  end

  @impl true
  def handle_info({RoguelandiaWeb.QuestLive.FormComponent, {:saved, quest}}, socket) do
    {:noreply, stream_insert(socket, :quests, quest)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quest = Game.get_quest!(id)
    {:ok, _} = Game.delete_quest(quest)

    {:noreply, stream_delete(socket, :quests, quest)}
  end
end
