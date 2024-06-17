defmodule Roguelandia.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi

  alias Roguelandia.Pawn.Player
  alias Roguelandia.Repo

  alias Roguelandia.Game.{Battle, BattlePlayer}


  def accept_player_battle(battle_id, player_id) do
    case Repo.get(Battle, battle_id) do
      nil ->
        {:error, "Battle not found"}

      %{active: true} ->
        {:error, "Too late, challenger is battling someone else."}
      battle ->
        case find_active_player_battle(battle.creator_id) do
          nil ->
            Multi.new()
            |> Multi.insert(:battle_player, %BattlePlayer{battle_id: battle_id, player_id: player_id})
            |> Multi.update(:battle, Battle.changeset(battle, %{active: true}))
            |> Repo.transaction()
            |> case do
              {:ok, _result} -> {:ok, battle}
              {:error, _failed_operation, changeset, _changes_so_far} -> {:error, changeset}
            end
          _battle ->
            {:error, "Too late, challenger is battling someone else."}
        end
    end
  end

  def find_or_create_empty_player_battle(player_id) do
    # If the player has an active battle, send them the active battle ID
    case find_active_player_battle(player_id) do
      nil ->
        case find_battle_without_participants(player_id) do
          nil ->
            create_battle(%{creator_id: player_id})
          battle ->
            {:ok, battle}
        end
      %{id: battle_id} ->
        {:has_battle, battle_id}
    end
  end

  def find_active_player_battle(player_id) do
    query =
      from p in Player,
        join: bp in assoc(p, :battle_players),
        join: b in assoc(bp, :battle),
        where: p.id == ^player_id,
        where: b.active == true,
        select: b

    Repo.one(query)
  end

  def find_battle_without_participants(creator_id) do
    query =
      from b in Battle,
        left_join: bp in BattlePlayer, on: bp.battle_id == b.id,
        where: b.creator_id == ^creator_id and is_nil(bp.battle_id),
        select: b

    case Repo.all(query) do
      [] -> nil
      [battle | _] -> battle
    end
  end

  @doc """
  Returns the list of battles.

  ## Examples

      iex> list_battles()
      [%Battle{}, ...]

  """
  def list_battles do
    Repo.all(Battle)
  end

  @doc """
  Gets a single battle.

  Raises `Ecto.NoResultsError` if the Battle does not exist.

  ## Examples

      iex> get_battle!(123)
      %Battle{}

      iex> get_battle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_battle!(id), do: Repo.get!(Battle, id)

  @doc """
  Creates a battle.

  ## Examples

      iex> create_battle(%{field: value})
      {:ok, %Battle{}}

      iex> create_battle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_battle(attrs \\ %{}) do
    %Battle{}
    |> Battle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a battle.

  ## Examples

      iex> update_battle(battle, %{field: new_value})
      {:ok, %Battle{}}

      iex> update_battle(battle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_battle(%Battle{} = battle, attrs) do
    battle
    |> Battle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a battle.

  ## Examples

      iex> delete_battle(battle)
      {:ok, %Battle{}}

      iex> delete_battle(battle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_battle(%Battle{} = battle) do
    Repo.delete(battle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking battle changes.

  ## Examples

      iex> change_battle(battle)
      %Ecto.Changeset{data: %Battle{}}

  """
  def change_battle(%Battle{} = battle, attrs \\ %{}) do
    Battle.changeset(battle, attrs)
  end

  # alias Roguelandia.Game.BattlePlayer

  @doc """
  Returns the list of battle_players.

  ## Examples

      iex> list_battle_players()
      [%BattlePlayer{}, ...]

  """
  def list_battle_players do
    Repo.all(BattlePlayer)
  end

  @doc """
  Gets a single battle_player.

  Raises `Ecto.NoResultsError` if the Battle player does not exist.

  ## Examples

      iex> get_battle_player!(123)
      %BattlePlayer{}

      iex> get_battle_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_battle_player!(id), do: Repo.get!(BattlePlayer, id)

  @doc """
  Creates a battle_player.

  ## Examples

      iex> create_battle_player(%{field: value})
      {:ok, %BattlePlayer{}}

      iex> create_battle_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_battle_player(attrs \\ %{}) do
    %BattlePlayer{}
    |> BattlePlayer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a battle_player.

  ## Examples

      iex> update_battle_player(battle_player, %{field: new_value})
      {:ok, %BattlePlayer{}}

      iex> update_battle_player(battle_player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_battle_player(%BattlePlayer{} = battle_player, attrs) do
    battle_player
    |> BattlePlayer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a battle_player.

  ## Examples

      iex> delete_battle_player(battle_player)
      {:ok, %BattlePlayer{}}

      iex> delete_battle_player(battle_player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_battle_player(%BattlePlayer{} = battle_player) do
    Repo.delete(battle_player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking battle_player changes.

  ## Examples

      iex> change_battle_player(battle_player)
      %Ecto.Changeset{data: %BattlePlayer{}}

  """
  def change_battle_player(%BattlePlayer{} = battle_player, attrs \\ %{}) do
    BattlePlayer.changeset(battle_player, attrs)
  end
end
