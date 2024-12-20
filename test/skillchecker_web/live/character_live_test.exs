defmodule SkillcheckerWeb.CharacterLiveTest do
  use SkillcheckerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Skillchecker.Factory

  @update_attrs %{accepted: true}

  defp setup_admin(%{conn: conn}) do
    admin = insert(:admin, accepted: true)
    conn = log_in_admin(conn, admin)

    %{admin: admin, conn: conn}
  end

  defp setup_character(_) do
    %{character: insert(:character)}
  end

  describe "Index" do
    setup [:setup_admin, :setup_character]

    test "lists all characters", %{conn: conn, character: character} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/characters")

      assert html =~ "Characters"
      assert html =~ character.name
    end

    test "updates character in listing", %{conn: conn, character: character} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/characters")

      assert index_live
             |> element("#characters-#{character.id} a", "Edit")
             |> render_click() =~ "Edit Character"

      assert_patch(index_live, ~p"/admin/characters/#{character}/edit")

      assert index_live
             |> form("#character-form", character: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/characters")
      assert character.accepted == true
    end

    test "deletes character in listing", %{conn: conn, character: character} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/characters")

      assert index_live |> element("#characters-#{character.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#characters-#{character.id}")
    end
  end

  describe "Show" do
    setup [:setup_admin, :setup_character]

    test "displays character", %{conn: conn, character: character} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/characters/#{character}")

      assert html =~ "Show Character"
      assert html =~ character.name
    end

    test "updates character within modal", %{conn: conn, character: character} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/characters/#{character}")

      assert show_live
             |> element("a", "Edit")
             |> render_click() =~ "Edit Character"

      assert_patch(show_live, ~p"/admin/characters/#{character}/show/edit")

      assert show_live
             |> form("#character-form", character: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/characters/#{character}")

      assert character.accepted == true
    end
  end
end
