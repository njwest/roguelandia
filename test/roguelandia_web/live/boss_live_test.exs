defmodule RoguelandiaWeb.BossLiveTest do
  use RoguelandiaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Roguelandia.NPCFixtures

  @create_attrs %{name: "some name", special: "some special", hp: 42, strength: 42, attack: "some attack", avatar_url: "some avatar_url"}
  @update_attrs %{name: "some updated name", special: "some updated special", hp: 43, strength: 43, attack: "some updated attack", avatar_url: "some updated avatar_url"}
  @invalid_attrs %{name: nil, special: nil, hp: nil, strength: nil, attack: nil, avatar_url: nil}

  defp create_boss(_) do
    boss = boss_fixture()
    %{boss: boss}
  end

  describe "Index" do
    setup [:create_boss]

    test "lists all bosses", %{conn: conn, boss: boss} do
      {:ok, _index_live, html} = live(conn, ~p"/bosses")

      assert html =~ "Listing Bosses"
      assert html =~ boss.name
    end

    test "saves new boss", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bosses")

      assert index_live |> element("a", "New Boss") |> render_click() =~
               "New Boss"

      assert_patch(index_live, ~p"/bosses/new")

      assert index_live
             |> form("#boss-form", boss: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#boss-form", boss: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bosses")

      html = render(index_live)
      assert html =~ "Boss created successfully"
      assert html =~ "some name"
    end

    test "updates boss in listing", %{conn: conn, boss: boss} do
      {:ok, index_live, _html} = live(conn, ~p"/bosses")

      assert index_live |> element("#bosses-#{boss.id} a", "Edit") |> render_click() =~
               "Edit Boss"

      assert_patch(index_live, ~p"/bosses/#{boss}/edit")

      assert index_live
             |> form("#boss-form", boss: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#boss-form", boss: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bosses")

      html = render(index_live)
      assert html =~ "Boss updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes boss in listing", %{conn: conn, boss: boss} do
      {:ok, index_live, _html} = live(conn, ~p"/bosses")

      assert index_live |> element("#bosses-#{boss.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bosses-#{boss.id}")
    end
  end

  describe "Show" do
    setup [:create_boss]

    test "displays boss", %{conn: conn, boss: boss} do
      {:ok, _show_live, html} = live(conn, ~p"/bosses/#{boss}")

      assert html =~ "Show Boss"
      assert html =~ boss.name
    end

    test "updates boss within modal", %{conn: conn, boss: boss} do
      {:ok, show_live, _html} = live(conn, ~p"/bosses/#{boss}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Boss"

      assert_patch(show_live, ~p"/bosses/#{boss}/show/edit")

      assert show_live
             |> form("#boss-form", boss: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#boss-form", boss: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/bosses/#{boss}")

      html = render(show_live)
      assert html =~ "Boss updated successfully"
      assert html =~ "some updated name"
    end
  end
end
