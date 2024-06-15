defmodule RoguelandiaWeb.GameLive do
  use RoguelandiaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
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

  @impl true
  def handle_info({RoguelandiaWeb.GameLive.ClassSelect, {:class_selected, player_result}}, socket) do
    case player_result do
      {:ok, player} ->
        {:noreply, assign(socket, :player, player)}
      {:error, message, player} ->
        {:noreply,
          socket
          |> assign(:player, player)
          |> put_flash(:error, message)
        }
    end
  end
end
