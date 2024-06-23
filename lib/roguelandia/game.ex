defmodule Roguelandia.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Ecto.Multi

  alias Roguelandia.{Repo, Pawn}
  alias RoguelandiaWeb.Endpoint

  alias Roguelandia.Pawn.Player
  alias Roguelandia.Game.{Battle, BattlePlayer}

  defp rotate_list_left([head | tail]) do
    tail ++ [head]
  end

  def process_attack(battle, attacker_id, target_id) do
    attacker = find_participant(battle, attacker_id)
    target = find_participant(battle, target_id)
    attack_result = Game.Rolls.attack_roll(attacker.strength)

    target_new_hp =
      case attack_result do
        {:hit, damage} ->
          target.hp - damage
        {:miss, _} ->
          nil
      end

    game_over? = if target_new_hp <= 0 and not is_nil(target_new_hp), do: true, else: false

    Multi.new()
    |> Multi.run(:maybe_hurt_target, fn _repo, _changes_so_far ->
      if is_nil(target_new_hp) do
        {:ok, nil}
      else
        Pawn.update_player(target, %{hp: target_new_hp})
      end
    end)
    |> Multi.run(:add_attacker_exp, fn _repo, _changes_so_far ->
      Pawn.update_player(attacker, %{experience: attacker.experience + 25})
    end)
    |> Multi.run(:battle, fn _repo, _changes_so_far ->
      attrs = %{turns: rotate_list_left(battle.turns), active: !game_over?}

      attrs =
        if game_over? and is_nil(battle.winner_id) do
          attrs
          |> Map.put(:winner_id, attacker_id)
          |> Map.put(:game_over_text, "#{target.name} was defeated, #{attacker.name} is victorious!")
        else
          attrs
        end

      update_battle(battle, attrs)
    end)
    |> Multi.run(:maybe_level_up_players, fn _repo, %{add_attacker_exp: %{experience: attacker_experience}} ->
        if game_over? do
          new_experience_total = attacker_experience + Levels.victory_exp(target.level)

          attacker_player_result = Levels.maybe_level_up(attacker, new_experience_total)

          target_player_result =
            if target_new_hp > 0 do
              Levels.maybe_level_up(target)
            else
              nil
            end

          case {attacker_player_result, target_player_result} do
            {{:error, changeset}, _} -> {:error, changeset}
            {_, {:error, changeset}} -> {:error, changeset}
            {{:ok, new_attacker_player}, {:ok, new_target_player}} -> {:ok, [new_attacker_player, new_target_player]}
            {{:ok, new_attacker_player}, nil} -> {:ok, [new_attacker_player, target]}
          end
        else
          {:ok, nil}
        end
      end)
    |> Repo.transaction()
    |> case do
      {:ok, _result} ->
        {:ok, attack_result}
      {:error, failed_operation, changeset, _changes_so_far} ->
        Logger.error("process_attack()/3 multi failed #{inspect(failed_operation)}: #{inspect(changeset)}")

        {:error, changeset}
    end
  end

  def process_flee(battle, player_id) do
    case Game.Rolls.flee_roll() do
      :success ->
        player = find_participant(battle, player_id)

        other_participants = Enum.filter(battle.participants, fn participant ->
          participant.id != player_id
        end)

        # NOTE assuming that battle is 1v1... FOR NOW! muahahaha
        remainer = hd(other_participants)

        Multi.new()
        |> Multi.run(:give_remainer_exp, fn _repo, _changes_so_far ->
          new_exp_total = remainer.experience + 30
          Levels.maybe_level_up(remainer, new_exp_total)
        end)
        |> Multi.run(:battle, fn _repo, _changes_so_far ->
          update_battle(battle, %{active: false, game_over_text: "#{player.name} fled, #{remainer.name} is victorious!", winner_id: remainer.id})
        end)
        |> Repo.transaction()
        |> case do
          {:ok, _result} ->
            {:ok, :fled}
          {:error, failed_operation, changeset, _changes_so_far} ->
            Logger.error("Successful process_flee()/3 multi error: #{inspect(failed_operation)}: #{inspect(changeset)}")

            {:error, changeset}
        end
      :failure ->
        # Player failed to flee, end player turn
        case update_battle(battle, %{turns: rotate_list_left(battle.turns)}) do
          {:ok, _result} ->
            {:ok, :failed}
          {:error, changeset} ->
            Logger.error("Successful process_flee()/3 multi error: #{inspect(changeset)}")

            {:error, changeset}
        end
    end
  end

  def find_participant(battle, player_id) do
    Enum.find(battle.participants, fn participant -> participant.id == player_id end)
  end

  def find_battle_with_participants(battle_id) do
    Repo.one(
      from b in Battle,
        where: b.id == ^battle_id,
        preload: [:participants]
    )
  end

  def accept_player_challenge(%{battle_id: battle_id, challenger_id: challenger_id} = _challenge, player_id) do
    case Repo.get(Battle, battle_id) do
      nil ->
        {:error, "Battle not found"}
      %{active: true} ->
        {:error, "Too late, challenger is battling someone else."}
      battle ->
        case find_active_player_battle(battle.creator_id) do
          nil ->
            turns = Enum.shuffle([player_id, challenger_id])

            Multi.new()
            |> Multi.insert(:challenged_battle_player, %BattlePlayer{battle_id: battle_id, player_id: player_id})
            |> Multi.insert(:challenger_battle_player, %BattlePlayer{battle_id: battle_id, player_id: challenger_id})
            |> Multi.update(:battle, Battle.changeset(battle, %{active: true, turns: turns}))
            |> Repo.transaction()
            |> case do
              {:ok, _result} ->
                Endpoint.broadcast("player:#{challenger_id}", "commence_battle", battle)
                Endpoint.broadcast("player:#{player_id}", "commence_battle", battle)

                {:ok, battle}
              {:error, failed_operation, changeset, _changes_so_far} ->
                Logger.error("Accept challenge multi failed #{inspect(failed_operation)}: #{inspect(changeset)}")

                {:error, changeset}
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
        order_by: [asc: b.id],
        select: b

    case Repo.all(query) do
      [active_battle | _] -> active_battle
      [] -> nil
    end
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
