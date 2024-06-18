defmodule Game.Rolls do
  @moduledoc """
  A module for action rolls, e.g. attack rolls.
  """

  def attack_roll(strength_modifier) do
    if miss?() do
      {:miss, 0}
    else
      # TODO MAYBE strength modifier should be a different roll
      # TODO MAYBE add armor class etc
      damage = roll_dice() + strength_modifier
      {:hit, damage}
    end
  end

  def flee_roll do
    if flee?() do
      :success
    else
      :failure
    end
  end

  defp flee?(flee_chance \\ 3) do
    :rand.uniform(flee_chance) == 1
  end

  defp miss?(miss_chance \\ 5) do
    :rand.uniform(miss_chance) == 1
  end

  defp roll_dice(dice_sides \\ 6) do
    :rand.uniform(dice_sides)
  end
end
