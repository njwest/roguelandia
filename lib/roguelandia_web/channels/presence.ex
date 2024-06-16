defmodule RoguelandiaWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :roguelandia,
    pubsub_server: Roguelandia.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {player_id, %{metas: [meta | metas]}} <- presences, into: %{} do
      {player_id, %{metas: [meta | metas], id: meta.id, name: meta.name, dom_id: "presence_#{meta.id}"}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {player_id, presence} <- joins do
      player_data = %{presence | metas: Map.fetch!(presences, player_id)}
      msg = {__MODULE__, {:join, player_data}}
      Phoenix.PubSub.local_broadcast(Roguelandia.PubSub, "proxy:#{topic}", msg)
    end

    for {player_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, player_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      player_data = %{presence | metas: metas}
      msg = {__MODULE__, {:leave, player_data}}
      Phoenix.PubSub.local_broadcast(Roguelandia.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end

  def list_online_players() do
    list("online_players")
    |> Enum.map(fn {_id, presence} -> presence
    end)
  end
  def track_player(player_id, params), do: track(self(), "online_players", player_id, params)

  def subscribe(), do: Phoenix.PubSub.subscribe(Roguelandia.PubSub, "proxy:online_players")
end
