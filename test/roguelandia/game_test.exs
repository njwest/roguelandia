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

  describe "quests" do
    alias Roguelandia.Game.Quest

    import Roguelandia.GameFixtures

    @invalid_attrs %{name: nil, config: nil}

    test "list_quests/0 returns all quests" do
      quest = quest_fixture()
      assert Game.list_quests() == [quest]
    end

    test "get_quest!/1 returns the quest with given id" do
      quest = quest_fixture()
      assert Game.get_quest!(quest.id) == quest
    end

    test "create_quest/1 with valid data creates a quest" do
      valid_attrs = %{name: "some name", config: %{}}

      assert {:ok, %Quest{} = quest} = Game.create_quest(valid_attrs)
      assert quest.name == "some name"
      assert quest.config == %{}
    end

    test "create_quest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_quest(@invalid_attrs)
    end

    test "update_quest/2 with valid data updates the quest" do
      quest = quest_fixture()
      update_attrs = %{name: "some updated name", config: %{}}

      assert {:ok, %Quest{} = quest} = Game.update_quest(quest, update_attrs)
      assert quest.name == "some updated name"
      assert quest.config == %{}
    end

    test "update_quest/2 with invalid data returns error changeset" do
      quest = quest_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_quest(quest, @invalid_attrs)
      assert quest == Game.get_quest!(quest.id)
    end

    test "delete_quest/1 deletes the quest" do
      quest = quest_fixture()
      assert {:ok, %Quest{}} = Game.delete_quest(quest)
      assert_raise Ecto.NoResultsError, fn -> Game.get_quest!(quest.id) end
    end

    test "change_quest/1 returns a quest changeset" do
      quest = quest_fixture()
      assert %Ecto.Changeset{} = Game.change_quest(quest)
    end
  end

  describe "player_quests" do
    alias Roguelandia.Game.PlayerQuest

    import Roguelandia.GameFixtures

    @invalid_attrs %{}

    test "list_player_quests/0 returns all player_quests" do
      player_quest = player_quest_fixture()
      assert Game.list_player_quests() == [player_quest]
    end

    test "get_player_quest!/1 returns the player_quest with given id" do
      player_quest = player_quest_fixture()
      assert Game.get_player_quest!(player_quest.id) == player_quest
    end

    test "create_player_quest/1 with valid data creates a player_quest" do
      valid_attrs = %{}

      assert {:ok, %PlayerQuest{} = player_quest} = Game.create_player_quest(valid_attrs)
    end

    test "create_player_quest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_player_quest(@invalid_attrs)
    end

    test "update_player_quest/2 with valid data updates the player_quest" do
      player_quest = player_quest_fixture()
      update_attrs = %{}

      assert {:ok, %PlayerQuest{} = player_quest} = Game.update_player_quest(player_quest, update_attrs)
    end

    test "update_player_quest/2 with invalid data returns error changeset" do
      player_quest = player_quest_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_player_quest(player_quest, @invalid_attrs)
      assert player_quest == Game.get_player_quest!(player_quest.id)
    end

    test "delete_player_quest/1 deletes the player_quest" do
      player_quest = player_quest_fixture()
      assert {:ok, %PlayerQuest{}} = Game.delete_player_quest(player_quest)
      assert_raise Ecto.NoResultsError, fn -> Game.get_player_quest!(player_quest.id) end
    end

    test "change_player_quest/1 returns a player_quest changeset" do
      player_quest = player_quest_fixture()
      assert %Ecto.Changeset{} = Game.change_player_quest(player_quest)
    end
  end
end
