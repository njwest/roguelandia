defmodule LiveArenaWeb.GameLive.ClassSelect do
  use LiveArenaWeb, :live_component

  alias LiveArena.Pawn
  alias LiveArena.Pawn.Player

  @impl true
  def render(assigns) do
    ~H"""
      <div class="flex vh-100">
        <.form for={@form} class="vh-100 flex flex-col" phx-submit="save" phx-change="validate" phx-target={@myself}>
            <div class="grid grid-cols-2 h-4/5">
                <.input type="image-radio" options={@class_opts} field={@form[:class_id]} />
            </div>
            <div class="dialogue-box h-1/5 flex">
                <div class="m-auto">
                    <%= if @class_selected do %>
                        <.button phx-disable-with="Saving...">Save Class</.button>
                    <% else %>
                        <h2 class="text-center text-2xl sm:text-4xl">Select a Class</h2>
                    <% end %>
                </div>
            </div>
        </.form>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Pawn.change_player(struct(Player, assigns.player))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:class_opts, Pawn.list_available_classes())
     |> assign(:class_selected, false)
     |> assign_form(changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"player" => %{"class_id" => class_id}}, socket) do
    {
      :noreply,
      assign(socket, :class_selected, !is_nil(class_id))
    }
  end

  def handle_event("save", %{"player" => %{"class_id" => class_id}}, socket) do
    case Pawn.set_player_class(socket.assigns.player.id, String.to_integer(class_id)) do
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
      player_result ->
        notify_parent({:class_selected, player_result})

        {:noreply, socket}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
