defmodule LiveArena.PawnTest do
  use LiveArena.DataCase

  alias LiveArena.Pawn

  describe "classes" do
    alias LiveArena.Pawn.Class

    import LiveArena.PawnFixtures

    @invalid_attrs %{name: nil, hp: nil, strength: nil, attack: nil, avatar_url: nil, active_limit: nil}

    test "list_classes/0 returns all classes" do
      class = class_fixture()
      assert Pawn.list_classes() == [class]
    end

    test "get_class!/1 returns the class with given id" do
      class = class_fixture()
      assert Pawn.get_class!(class.id) == class
    end

    test "create_class/1 with valid data creates a class" do
      valid_attrs = %{name: "some name", hp: 42, strength: 42, attack: "some attack", avatar_url: "some avatar_url", active_limit: 42}

      assert {:ok, %Class{} = class} = Pawn.create_class(valid_attrs)
      assert class.name == "some name"
      assert class.hp == 42
      assert class.strength == 42
      assert class.attack == "some attack"
      assert class.avatar_url == "some avatar_url"
      assert class.active_limit == 42
    end

    test "create_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pawn.create_class(@invalid_attrs)
    end

    test "update_class/2 with valid data updates the class" do
      class = class_fixture()
      update_attrs = %{name: "some updated name", hp: 43, strength: 43, attack: "some updated attack", avatar_url: "some updated avatar_url", active_limit: 43}

      assert {:ok, %Class{} = class} = Pawn.update_class(class, update_attrs)
      assert class.name == "some updated name"
      assert class.hp == 43
      assert class.strength == 43
      assert class.attack == "some updated attack"
      assert class.avatar_url == "some updated avatar_url"
      assert class.active_limit == 43
    end

    test "update_class/2 with invalid data returns error changeset" do
      class = class_fixture()
      assert {:error, %Ecto.Changeset{}} = Pawn.update_class(class, @invalid_attrs)
      assert class == Pawn.get_class!(class.id)
    end

    test "delete_class/1 deletes the class" do
      class = class_fixture()
      assert {:ok, %Class{}} = Pawn.delete_class(class)
      assert_raise Ecto.NoResultsError, fn -> Pawn.get_class!(class.id) end
    end

    test "change_class/1 returns a class changeset" do
      class = class_fixture()
      assert %Ecto.Changeset{} = Pawn.change_class(class)
    end
  end
end
