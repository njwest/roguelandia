defmodule LiveArenaWeb.PlayerLive do

  use LiveArenaWeb, :live_view
  alias LiveArena.Pawn

  @impl true
  def mount(_params, _session, socket) do
    changeset = Pawn.change_player(socket.assigns.current_user.player)
    {
      :ok,
      socket
      |> assign(:class_opts, Pawn.list_available_classes())
      |> assign(:player, socket.assigns.current_user.player)
      |> assign(:class_selected, false)
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

  @impl true
  def handle_event("save", %{"player" => %{"class_id" => class_id}}, socket) do
    case Pawn.set_player_class(socket.assigns.player.id, String.to_integer(class_id)) do
      {:ok, _player} ->
        {:noreply, redirect(socket, to: "/home")}
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  @impl true
  def handle_event("validate", %{"player" => %{"class_id" => class_id}}, socket) do
    {
      :noreply,
      assign(socket, :class_selected, !is_nil(class_id))
    }
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
