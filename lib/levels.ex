defmodule Levels do
  @moduledoc """
  A module for calculating victory experience and levels in a game.
  """
  alias Roguelandia.Pawn

  @base_level_exp 100
  @base_victory_exp 50

  @attribute_increment 2

  @doc """
  Returns the amount of experience gained from defeating an opponent.

  ## Example

    iex> victory_exp(opponent_level)
    1000

  """
  def victory_exp(opponent_level) do
    round(@base_victory_exp * :math.pow(1.2, opponent_level))
  end

  @doc """
  Maybe level up a player based on their experience.

  ## Example

    iex> maybe_level_up(player)
    {:ok, player} | {:error, changeset}

  """
  def maybe_level_up(player) do
    maybe_level_up(player, player.experience)
  end

  @doc """
  Maybe level up a player based on an experience total.
  This is used for when a player gains experience at the same time
  as a level check, e.g. they win a battle.

  ## Example

    iex> maybe_level_up(player, experience_total)
    {:ok, player} | {:error, changeset}

  """
  def maybe_level_up(player, experience_total) when is_integer(experience_total) do
    if level_up?(player.level, experience_total) do
      level_up_player(player, experience_total)
    else
      if experience_total > player.experience do
        Pawn.update_player(player, %{experience: experience_total})
      else
        {:ok, player}
      end
    end
  end

  defp level_up_player(player, experience_total) when is_integer(experience_total) do
    new_max_hp = new_max_hp(player.level + 1, player.hp)

    Pawn.update_player(player, %{
      experience: experience_total,
      level: player.level + 1,
      strength: increase_attribute(player.level + 1, player.strength),
      max_hp: new_max_hp,
      hp: new_max_hp
    })
  end

  defp level_up?(level, experience) do
    required_exp = level_exp_threshold(level)
    experience >= required_exp
  end

  defp increase_attribute(level, base_attribute) do
    base_attribute + (level - 1) * @attribute_increment
  end

  # Exponential HP increase
  defp new_max_hp(level, base_hp) do
    round(base_hp * :math.pow(1.15, level - 1))
  end

  # Quadratic experience threshold
  defp level_exp_threshold(level) do
    @base_level_exp * level * level
  end
end
