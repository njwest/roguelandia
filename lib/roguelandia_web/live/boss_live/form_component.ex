defmodule RoguelandiaWeb.BossLive.FormComponent do
  use RoguelandiaWeb, :live_component

  alias Roguelandia.NPC

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Manage boss records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="boss-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:hp]} type="number" label="Hp" />
        <.input field={@form[:strength]} type="number" label="Strength" />
        <.input field={@form[:attack]} type="text" label="Attack" />
        <.input field={@form[:special]} type="text" label="Special" />
        <.input field={@form[:avatar_url]} type="text" label="Avatar url" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Boss</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{boss: boss} = assigns, socket) do
    changeset = NPC.change_boss(boss)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"boss" => boss_params}, socket) do
    changeset =
      socket.assigns.boss
      |> NPC.change_boss(boss_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"boss" => boss_params}, socket) do
    save_boss(socket, socket.assigns.action, boss_params)
  end

  defp save_boss(socket, :edit, boss_params) do
    case NPC.update_boss(socket.assigns.boss, boss_params) do
      {:ok, boss} ->
        notify_parent({:saved, boss})

        {:noreply,
         socket
         |> put_flash(:info, "Boss updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_boss(socket, :new, boss_params) do
    case NPC.create_boss(boss_params) do
      {:ok, boss} ->
        notify_parent({:saved, boss})

        {:noreply,
         socket
         |> put_flash(:info, "Boss created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
