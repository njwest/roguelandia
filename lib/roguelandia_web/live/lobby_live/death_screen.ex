defmodule RoguelandiaWeb.LobbyLive.DeathScreen do
  use RoguelandiaWeb, :live_component

  alias Roguelandia.Pawn
  alias Roguelandia.Pawn.Player

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <.centered_dialogue id="death-screen" class="max-w-lg">
          <.header>
            <%= @player.name %> has been defeated.
          </.header>
          <p class="text-2xl">
            You reached Level <%= @player.level %> with <%= @player.name %>.
          </p>
          <.simple_form
            for={@form}
            id="new-player-form"
            phx-target={@myself}
            phx-submit="save"
          >
            <p class="text-2xl">
              Create a new player to continue!
            </p>
            <.input field={@form[:name]} type="text" label="New Player Name" required />
            <:actions>
              <button class="hollow-button" phx-disable-with="Saving...">Continue</button>
            </:actions>
          </.simple_form>
        </.centered_dialogue>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Pawn.change_player(struct(Player, assigns.player))

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
    }
  end

  @impl true
  def handle_event("save", %{"player" => %{"name" => name}}, %{assigns: %{user_id: user_id}} = socket) do
    case Pawn.create_player(%{"name" => name, "user_id" => user_id}) do
      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
      {:ok, _player_result} ->
        # Push navigate to re-render the lobby
        {:noreply, push_navigate(socket, to: ~p"/lobby")}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
