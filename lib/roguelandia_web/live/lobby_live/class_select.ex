defmodule RoguelandiaWeb.LobbyLive.ClassSelect do
  use RoguelandiaWeb, :live_component

  alias Roguelandia.Pawn
  alias Roguelandia.Pawn.Player

  @impl true
  def render(assigns) do
    ~H"""
      <div class="vh-100 w-full">
        <.form for={@form} class="flex flex-col" phx-submit="save" phx-change="validate" phx-target={@myself}>
          <div class="grid grid-cols-2">
              <.input type="image-radio" options={@class_opts} field={@form[:class_id]} />
          </div>
          <div class="w-full z-10 bottom-0 absolute">
            <%= if @class_selected do %>
                <.button class="w-full" phx-disable-with="Saving...">
                  <h2 class="text-center text-2xl sm:text-4xl bg-inherit">Continue</h2>
                </.button>
            <% else %>
              <.button class="bg-black text-white w-full" disabled>
                <h2 class="text-center text-2xl sm:text-4xl">Select a Class</h2>
              </.button>
            <% end %>
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
  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      %Player{}
      |> Player.changeset(player_params)
      |> Map.put(:action, :validate)

    class_selected = Map.has_key?(player_params, "class_id") && player_params["class_id"] != nil

    {
      :noreply,
      socket
      |> assign(:class_selected, class_selected)
      |> assign_form(changeset)
    }
  end

  def handle_event("save", %{"player" => %{"class_id" => class_id}}, socket) do
    case Pawn.set_player_class(socket.assigns.player.id, String.to_integer(class_id)) do
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
      {:ok, _player_result} ->
        # Push navigate to re-render the lobby
        {:noreply, push_navigate(socket, to: ~p"/lobby")}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
