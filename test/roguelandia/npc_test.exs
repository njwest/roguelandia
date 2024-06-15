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
end
