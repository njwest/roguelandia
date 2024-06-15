defmodule Roguelandia.NPCFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Roguelandia.NPC` context.
  """

  @doc """
  Generate a boss.
  """
  def boss_fixture(attrs \\ %{}) do
    {:ok, boss} =
      attrs
      |> Enum.into(%{
        attack: "some attack",
        avatar_url: "some avatar_url",
        hp: 42,
        name: "some name",
        special: "some special",
        strength: 42
      })
      |> Roguelandia.NPC.create_boss()

    boss
  end
end
