defmodule Roguelandia.GameTest do
  use Roguelandia.DataCase

  alias Roguelandia.Game

  describe "battles" do
    alias Roguelandia.Game.Battle

    import Roguelandia.GameFixtures

    @invalid_attrs %{}

    test "list_battles/0 returns all battles" do
      battle = battle_fixture()
      assert Game.list_battles() == [battle]
    end

    test "get_battle!/1 returns the battle with given id" do
      battle = battle_fixture()
      assert Game.get_battle!(battle.id) == battle
    end

    test "create_battle/1 with valid data creates a battle" do
      valid_attrs = %{}

      assert {:ok, %Battle{} = battle} = Game.create_battle(valid_attrs)
    end

    test "create_battle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_battle(@invalid_attrs)
    end

    test "update_battle/2 with valid data updates the battle" do
      battle = battle_fixture()
      update_attrs = %{}

      assert {:ok, %Battle{} = battle} = Game.update_battle(battle, update_attrs)
    end

    test "update_battle/2 with invalid data returns error changeset" do
      battle = battle_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_battle(battle, @invalid_attrs)
      assert battle == Game.get_battle!(battle.id)
    end

    test "delete_battle/1 deletes the battle" do
      battle = battle_fixture()
      assert {:ok, %Battle{}} = Game.delete_battle(battle)
      assert_raise Ecto.NoResultsError, fn -> Game.get_battle!(battle.id) end
    end

    test "change_battle/1 returns a battle changeset" do
      battle = battle_fixture()
      assert %Ecto.Changeset{} = Game.change_battle(battle)
    end
  end

  describe "battle_players" do
    alias Roguelandia.Game.BattlePlayer

    import Roguelandia.GameFixtures

    @invalid_attrs %{}

    test "list_battle_players/0 returns all battle_players" do
      battle_player = battle_player_fixture()
      assert Game.list_battle_players() == [battle_player]
    end

    test "get_battle_player!/1 returns the battle_player with given id" do
      battle_player = battle_player_fixture()
      assert Game.get_battle_player!(battle_player.id) == battle_player
    end

    test "create_battle_player/1 with valid data creates a battle_player" do
      valid_attrs = %{}

      assert {:ok, %BattlePlayer{} = battle_player} = Game.create_battle_player(valid_attrs)
    end

    test "create_battle_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_battle_player(@invalid_attrs)
    end

    test "update_battle_player/2 with valid data updates the battle_player" do
      battle_player = battle_player_fixture()
      update_attrs = %{}

      assert {:ok, %BattlePlayer{} = battle_player} = Game.update_battle_player(battle_player, update_attrs)
    end

    test "update_battle_player/2 with invalid data returns error changeset" do
      battle_player = battle_player_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_battle_player(battle_player, @invalid_attrs)
      assert battle_player == Game.get_battle_player!(battle_player.id)
    end

    test "delete_battle_player/1 deletes the battle_player" do
      battle_player = battle_player_fixture()
      assert {:ok, %BattlePlayer{}} = Game.delete_battle_player(battle_player)
      assert_raise Ecto.NoResultsError, fn -> Game.get_battle_player!(battle_player.id) end
    end

    test "change_battle_player/1 returns a battle_player changeset" do
      battle_player = battle_player_fixture()
      assert %Ecto.Changeset{} = Game.change_battle_player(battle_player)
    end
  end
end
