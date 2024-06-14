defmodule LiveArenaWeb.ClassLive.FormComponent do
  use LiveArenaWeb, :live_component

  alias LiveArena.Pawn

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage class records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="class-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:hp]} type="number" label="Hp" />
        <.input field={@form[:strength]} type="number" label="Strength" />
        <.input field={@form[:attack]} type="text" label="Attack" />
        <.input field={@form[:avatar_url]} type="text" label="Avatar url" />
        <.input field={@form[:active_limit]} type="number" label="Active limit" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Class</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{class: class} = assigns, socket) do
    changeset = Pawn.change_class(class)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"class" => class_params}, socket) do
    changeset =
      socket.assigns.class
      |> Pawn.change_class(class_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"class" => class_params}, socket) do
    save_class(socket, socket.assigns.action, class_params)
  end

  defp save_class(socket, :edit, class_params) do
    case Pawn.update_class(socket.assigns.class, class_params) do
      {:ok, class} ->
        notify_parent({:saved, class})

        {:noreply,
         socket
         |> put_flash(:info, "Class updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_class(socket, :new, class_params) do
    case Pawn.create_class(class_params) do
      {:ok, class} ->
        notify_parent({:saved, class})

        {:noreply,
         socket
         |> put_flash(:info, "Class created successfully")
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
