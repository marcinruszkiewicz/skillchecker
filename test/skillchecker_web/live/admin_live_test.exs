defmodule SkillcheckerWeb.AdminLiveTest do
  use SkillcheckerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Skillchecker.AccountsFixtures

  @update_attrs %{name: "New Name", accepted: false}
  @invalid_attrs %{name: nil, accepted: false}

  describe "Index" do
    setup %{conn: conn} do
      password = valid_admin_password()
      admin = admin_fixture(%{password: password})
      %{conn: log_in_admin(conn, admin), admin: admin}
    end

    test "lists all admins", %{conn: conn, admin: admin} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/admins")

      assert html =~ "Listing Admins"
      assert html =~ admin.email
    end

    test "updates admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/admins")

      assert index_live |> element("#admins-#{admin.id} a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(index_live, ~p"/admin/admins/#{admin}/edit")

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#admin-form", admin: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/admins")

      html = render(index_live)
      assert html =~ "Admin updated successfully"
      assert html =~ "some updated email"
    end
  end

  describe "Show" do
    setup %{conn: conn} do
      password = valid_admin_password()
      admin = admin_fixture(%{password: password})
      %{conn: log_in_admin(conn, admin), admin: admin}
    end

    test "displays admin", %{conn: conn, admin: admin} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/admins/#{admin}")

      assert html =~ "Show Admin"
      assert html =~ admin.email
    end

    test "updates admin within modal", %{conn: conn, admin: admin} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/admins/#{admin}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(show_live, ~p"/admin/admins/#{admin}/show/edit")

      assert show_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#admin-form", admin: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/admins/#{admin}")

      html = render(show_live)
      assert html =~ "Admin updated successfully"
      assert html =~ "some updated email"
    end
  end
end
