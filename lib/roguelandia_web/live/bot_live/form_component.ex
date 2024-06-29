defmodule RoguelandiaWeb.BotLive.FormComponent do
  use RoguelandiaWeb, :live_component

  alias Roguelandia.NPC

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage bot records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="bot-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:level]} type="number" label="Level" />
        <.input field={@form[:experience]} type="number" label="Experience" />
        <.input field={@form[:special]} type="text" label="Special" />
        <.input field={@form[:hp]} type="number" label="Hp" />
        <.input field={@form[:max_hp]} type="number" label="Max hp" />
        <.input field={@form[:attack]} type="text" label="Attack" />
        <.input field={@form[:strength]} type="number" label="Strength" />
        <.input field={@form[:sprite_url]} type="text" label="Sprite url" />
        <.input
          field={@form[:attitude]}
          type="select"
          label="Attitude"
          prompt="Choose a value"
          options={Ecto.Enum.values(Roguelandia.NPC.Bot, :attitude)}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Bot</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{bot: bot} = assigns, socket) do
    changeset = NPC.change_bot(bot)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"bot" => bot_params}, socket) do
    changeset =
      socket.assigns.bot
      |> NPC.change_bot(bot_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"bot" => bot_params}, socket) do
    save_bot(socket, socket.assigns.action, bot_params)
  end

  defp save_bot(socket, :edit, bot_params) do
    case NPC.update_bot(socket.assigns.bot, bot_params) do
      {:ok, bot} ->
        notify_parent({:saved, bot})

        {:noreply,
         socket
         |> put_flash(:info, "Bot updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_bot(socket, :new, bot_params) do
    case NPC.create_bot(bot_params) do
      {:ok, bot} ->
        notify_parent({:saved, bot})

        {:noreply,
         socket
         |> put_flash(:info, "Bot created successfully")
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
