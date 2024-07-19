defmodule SkillcheckerWeb.SkillsetLiveTest do
  use SkillcheckerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Skillchecker.SkillsetsFixtures

  @create_attrs %{name: "some name", skills: "some skills"}
  @update_attrs %{name: "some updated name", skills: "some updated skills"}
  @invalid_attrs %{name: nil, skills: nil}

  defp create_skillset(_) do
    skillset = skillset_fixture()
    %{skillset: skillset}
  end

  describe "Index" do
    setup [:create_skillset]

    test "lists all skillsets", %{conn: conn, skillset: skillset} do
      {:ok, _index_live, html} = live(conn, ~p"/skillsets")

      assert html =~ "Listing Skillsets"
      assert html =~ skillset.name
    end

    test "saves new skillset", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/skillsets")

      assert index_live |> element("a", "New Skillset") |> render_click() =~
               "New Skillset"

      assert_patch(index_live, ~p"/skillsets/new")

      assert index_live
             |> form("#skillset-form", skillset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#skillset-form", skillset: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/skillsets")

      html = render(index_live)
      assert html =~ "Skillset created successfully"
      assert html =~ "some name"
    end

    test "updates skillset in listing", %{conn: conn, skillset: skillset} do
      {:ok, index_live, _html} = live(conn, ~p"/skillsets")

      assert index_live |> element("#skillsets-#{skillset.id} a", "Edit") |> render_click() =~
               "Edit Skillset"

      assert_patch(index_live, ~p"/skillsets/#{skillset}/edit")

      assert index_live
             |> form("#skillset-form", skillset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#skillset-form", skillset: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/skillsets")

      html = render(index_live)
      assert html =~ "Skillset updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes skillset in listing", %{conn: conn, skillset: skillset} do
      {:ok, index_live, _html} = live(conn, ~p"/skillsets")

      assert index_live |> element("#skillsets-#{skillset.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#skillsets-#{skillset.id}")
    end
  end

  describe "Show" do
    setup [:create_skillset]

    test "displays skillset", %{conn: conn, skillset: skillset} do
      {:ok, _show_live, html} = live(conn, ~p"/skillsets/#{skillset}")

      assert html =~ "Show Skillset"
      assert html =~ skillset.name
    end

    test "updates skillset within modal", %{conn: conn, skillset: skillset} do
      {:ok, show_live, _html} = live(conn, ~p"/skillsets/#{skillset}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Skillset"

      assert_patch(show_live, ~p"/skillsets/#{skillset}/show/edit")

      assert show_live
             |> form("#skillset-form", skillset: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#skillset-form", skillset: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/skillsets/#{skillset}")

      html = render(show_live)
      assert html =~ "Skillset updated successfully"
      assert html =~ "some updated name"
    end
  end
end
