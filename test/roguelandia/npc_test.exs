defmodule Roguelandia.NPCTest do
  use Roguelandia.DataCase

  alias Roguelandia.NPC

  describe "bosses" do
    alias Roguelandia.NPC.Boss

    import Roguelandia.NPCFixtures

    @invalid_attrs %{name: nil, special: nil, hp: nil, strength: nil, attack: nil, avatar_url: nil}

    test "list_bosses/0 returns all bosses" do
      boss = boss_fixture()
      assert NPC.list_bosses() == [boss]
    end

    test "get_boss!/1 returns the boss with given id" do
      boss = boss_fixture()
      assert NPC.get_boss!(boss.id) == boss
    end

    test "create_boss/1 with valid data creates a boss" do
      valid_attrs = %{name: "some name", special: "some special", hp: 42, strength: 42, attack: "some attack", avatar_url: "some avatar_url"}

      assert {:ok, %Boss{} = boss} = NPC.create_boss(valid_attrs)
      assert boss.name == "some name"
      assert boss.special == "some special"
      assert boss.hp == 42
      assert boss.strength == 42
      assert boss.attack == "some attack"
      assert boss.avatar_url == "some avatar_url"
    end

    test "create_boss/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = NPC.create_boss(@invalid_attrs)
    end

    test "update_boss/2 with valid data updates the boss" do
      boss = boss_fixture()
      update_attrs = %{name: "some updated name", special: "some updated special", hp: 43, strength: 43, attack: "some updated attack", avatar_url: "some updated avatar_url"}

      assert {:ok, %Boss{} = boss} = NPC.update_boss(boss, update_attrs)
      assert boss.name == "some updated name"
      assert boss.special == "some updated special"
      assert boss.hp == 43
      assert boss.strength == 43
      assert boss.attack == "some updated attack"
      assert boss.avatar_url == "some updated avatar_url"
    end

    test "update_boss/2 with invalid data returns error changeset" do
      boss = boss_fixture()
      assert {:error, %Ecto.Changeset{}} = NPC.update_boss(boss, @invalid_attrs)
      assert boss == NPC.get_boss!(boss.id)
    end

    test "delete_boss/1 deletes the boss" do
      boss = boss_fixture()
      assert {:ok, %Boss{}} = NPC.delete_boss(boss)
      assert_raise Ecto.NoResultsError, fn -> NPC.get_boss!(boss.id) end
    end

    test "change_boss/1 returns a boss changeset" do
      boss = boss_fixture()
      assert %Ecto.Changeset{} = NPC.change_boss(boss)
    end
  end

  describe "bots" do
    alias Roguelandia.NPC.Bot

    import Roguelandia.NPCFixtures

    @invalid_attrs %{name: nil, level: nil, special: nil, experience: nil, hp: nil, max_hp: nil, attack: nil, strength: nil, sprite_url: nil, attitude: nil}

    test "list_bots/0 returns all bots" do
      bot = bot_fixture()
      assert NPC.list_bots() == [bot]
    end

    test "get_bot!/1 returns the bot with given id" do
      bot = bot_fixture()
      assert NPC.get_bot!(bot.id) == bot
    end

    test "create_bot/1 with valid data creates a bot" do
      valid_attrs = %{name: "some name", level: 42, special: "some special", experience: 42, hp: 42, max_hp: 42, attack: "some attack", strength: 42, sprite_url: "some sprite_url", attitude: :hostile}

      assert {:ok, %Bot{} = bot} = NPC.create_bot(valid_attrs)
      assert bot.name == "some name"
      assert bot.level == 42
      assert bot.special == "some special"
      assert bot.experience == 42
      assert bot.hp == 42
      assert bot.max_hp == 42
      assert bot.attack == "some attack"
      assert bot.strength == 42
      assert bot.sprite_url == "some sprite_url"
      assert bot.attitude == :hostile
    end

    test "create_bot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = NPC.create_bot(@invalid_attrs)
    end

    test "update_bot/2 with valid data updates the bot" do
      bot = bot_fixture()
      update_attrs = %{name: "some updated name", level: 43, special: "some updated special", experience: 43, hp: 43, max_hp: 43, attack: "some updated attack", strength: 43, sprite_url: "some updated sprite_url", attitude: :friendly}

      assert {:ok, %Bot{} = bot} = NPC.update_bot(bot, update_attrs)
      assert bot.name == "some updated name"
      assert bot.level == 43
      assert bot.special == "some updated special"
      assert bot.experience == 43
      assert bot.hp == 43
      assert bot.max_hp == 43
      assert bot.attack == "some updated attack"
      assert bot.strength == 43
      assert bot.sprite_url == "some updated sprite_url"
      assert bot.attitude == :friendly
    end

    test "update_bot/2 with invalid data returns error changeset" do
      bot = bot_fixture()
      assert {:error, %Ecto.Changeset{}} = NPC.update_bot(bot, @invalid_attrs)
      assert bot == NPC.get_bot!(bot.id)
    end

    test "delete_bot/1 deletes the bot" do
      bot = bot_fixture()
      assert {:ok, %Bot{}} = NPC.delete_bot(bot)
      assert_raise Ecto.NoResultsError, fn -> NPC.get_bot!(bot.id) end
    end

    test "change_bot/1 returns a bot changeset" do
      bot = bot_fixture()
      assert %Ecto.Changeset{} = NPC.change_bot(bot)
    end
  end
end
