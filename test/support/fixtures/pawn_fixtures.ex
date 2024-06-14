defmodule LiveArena.PawnFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveArena.Pawn` context.
  """

  @doc """
  Generate a class.
  """
  def class_fixture(attrs \\ %{}) do
    {:ok, class} =
      attrs
      |> Enum.into(%{
        active_limit: 42,
        attack: "some attack",
        avatar_url: "some avatar_url",
        hp: 42,
        name: "some name",
        strength: 42
      })
      |> LiveArena.Pawn.create_class()

    class
  end
end
