defmodule SkillcheckerWeb.SkillsetLiveTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Skillchecker.Factory

  @create_attrs %{name: "some name", skill_list: "Amarr Battleship V\nCaldari Battleship V"}
  @update_attrs %{name: "some updated name", skill_list: "Gallente Battleship V"}
  @invalid_attrs %{name: nil, skill_list: nil}

  defp setup_admin(%{conn: conn}) do
    admin = insert(:admin, accepted: true)
    conn = log_in_admin(conn, admin)

    %{admin: admin, conn: conn}
  end

  defp setup_skills(_) do
    insert(:item, name: "Caldari Battleship", eveid: 1)
    insert(:item, name: "Amarr Battleship", eveid: 2)
    insert(:item, name: "Gallente Battleship", eveid: 3)
    skillset = insert(:skillset)

    %{skillset: skillset}
  end

  describe "Index" do
    setup [:setup_admin, :setup_skills]

    test "lists all skillsets", %{conn: conn, skillset: skillset} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/skillsets")

      assert html =~ "Skillsets"
      assert html =~ skillset.name
    end

    test "saves new skillset", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/skillsets")

      assert index_live |> element("a", "New Skillset") |> render_click() =~
               "New Skillset"

      assert_patch(index_live, ~p"/admin/skillsets/new")

      assert index_live
             |> form("#skillset-form", skillset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#skillset-form", skillset: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/skillsets")

      html = render(index_live)
      assert html =~ "some name"
    end

    test "updates skillset in listing", %{conn: conn, skillset: skillset} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/skillsets")

      assert index_live
             |> element("#skillsets-#{skillset.id} a", "Edit")
             |> render_click() =~ "Edit Skillset"

      assert_patch(index_live, ~p"/admin/skillsets/#{skillset}/edit")

      assert index_live
             |> form("#skillset-form", skillset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#skillset-form", skillset: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/skillsets")

      html = render(index_live)
      assert html =~ "some updated name"
    end

    test "deletes skillset in listing", %{conn: conn, skillset: skillset} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/skillsets")

      assert index_live |> element("#skillsets-#{skillset.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#skillsets-#{skillset.id}")
    end
  end

  describe "Show" do
    setup [:setup_admin, :setup_skills]

    test "displays skillset", %{conn: conn, skillset: skillset} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/skillsets/#{skillset}")

      assert html =~ "Show Skillset"
      assert html =~ skillset.name
    end

    test "updates skillset within modal", %{conn: conn, skillset: skillset} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/skillsets/#{skillset}")

      assert show_live
             |> element("a", "Edit")
             |> render_click() =~ "Edit Skillset"

      assert_patch(show_live, ~p"/admin/skillsets/#{skillset}/show/edit")

      assert show_live
             |> form("#skillset-form", skillset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#skillset-form", skillset: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/skillsets/#{skillset}")

      html = render(show_live)
      assert html =~ "some updated name"
    end
  end
end
