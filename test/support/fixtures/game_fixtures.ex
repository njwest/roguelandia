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

  @doc """
  Generate a quest.
  """
  def quest_fixture(attrs \\ %{}) do
    {:ok, quest} =
      attrs
      |> Enum.into(%{
        config: %{},
        name: "some name"
      })
      |> Roguelandia.Game.create_quest()

    quest
  end

  @doc """
  Generate a player_quest.
  """
  def player_quest_fixture(attrs \\ %{}) do
    {:ok, player_quest} =
      attrs
      |> Enum.into(%{

      })
      |> Roguelandia.Game.create_player_quest()

    player_quest
  end
end
