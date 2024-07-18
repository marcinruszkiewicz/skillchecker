defmodule SkillcheckerWeb.AdminLiveTest do
  use SkillcheckerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Skillchecker.AdminsFixtures

  @create_attrs %{email: "some email", accepted: true}
  @update_attrs %{email: "some updated email", accepted: false}
  @invalid_attrs %{email: nil, accepted: false}

  defp create_admin(_) do
    admin = admin_fixture()
    %{admin: admin}
  end

  describe "Index" do
    setup [:create_admin]

    test "lists all admins", %{conn: conn, admin: admin} do
      {:ok, _index_live, html} = live(conn, ~p"/admins")

      assert html =~ "Listing Admins"
      assert html =~ admin.email
    end

    test "saves new admin", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admins")

      assert index_live |> element("a", "New Admin") |> render_click() =~
               "New Admin"

      assert_patch(index_live, ~p"/admins/new")

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#admin-form", admin: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admins")

      html = render(index_live)
      assert html =~ "Admin created successfully"
      assert html =~ "some email"
    end

    test "updates admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, ~p"/admins")

      assert index_live |> element("#admins-#{admin.id} a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(index_live, ~p"/admins/#{admin}/edit")

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#admin-form", admin: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admins")

      html = render(index_live)
      assert html =~ "Admin updated successfully"
      assert html =~ "some updated email"
    end

    test "deletes admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, ~p"/admins")

      assert index_live |> element("#admins-#{admin.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#admins-#{admin.id}")
    end
  end

  describe "Show" do
    setup [:create_admin]

    test "displays admin", %{conn: conn, admin: admin} do
      {:ok, _show_live, html} = live(conn, ~p"/admins/#{admin}")

      assert html =~ "Show Admin"
      assert html =~ admin.email
    end

    test "updates admin within modal", %{conn: conn, admin: admin} do
      {:ok, show_live, _html} = live(conn, ~p"/admins/#{admin}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(show_live, ~p"/admins/#{admin}/show/edit")

      assert show_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#admin-form", admin: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admins/#{admin}")

      html = render(show_live)
      assert html =~ "Admin updated successfully"
      assert html =~ "some updated email"
    end
  end
end
