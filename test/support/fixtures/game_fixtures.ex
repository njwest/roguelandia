defmodule Roguelandia.GameFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Roguelandia.Game` context.
  """

  @doc """
  Generate a battle.
  """
  def battle_fixture(attrs \\ %{}) do
    {:ok, battle} =
      attrs
      |> Enum.into(%{

      })
      |> Roguelandia.Game.create_battle()

    battle
  end

  @doc """
  Generate a battle_player.
  """
  def battle_player_fixture(attrs \\ %{}) do
    {:ok, battle_player} =
      attrs
      |> Enum.into(%{

      })
      |> Roguelandia.Game.create_battle_player()

    battle_player
  end
end
