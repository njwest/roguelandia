defmodule RoguelandiaWeb.BotLive.Index do
  use RoguelandiaWeb, :live_view

  alias Roguelandia.NPC
  alias Roguelandia.NPC.Bot

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :bots, NPC.list_bots())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bot")
    |> assign(:bot, NPC.get_bot!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bot")
    |> assign(:bot, %Bot{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bots")
    |> assign(:bot, nil)
  end

  @impl true
  def handle_info({RoguelandiaWeb.BotLive.FormComponent, {:saved, bot}}, socket) do
    {:noreply, stream_insert(socket, :bots, bot)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bot = NPC.get_bot!(id)
    {:ok, _} = NPC.delete_bot(bot)

    {:noreply, stream_delete(socket, :bots, bot)}
  end
end
