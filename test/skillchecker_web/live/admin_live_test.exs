defmodule SkillcheckerWeb.AdminLiveTest do
  use SkillcheckerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Skillchecker.AccountsFixtures

  @update_attrs %{accepted: true}

  describe "Index" do
    setup %{conn: conn} do
      password = valid_admin_password()
      admin = accepted_admin_fixture(%{password: password})
      %{conn: log_in_admin(conn, admin), admin: admin}
    end

    test "lists all admins", %{conn: conn, admin: admin} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/admins")

      assert html =~ "Listing Admins"
      assert html =~ admin.name
    end

    test "updates admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/admins")

      assert index_live |> element("#admins-#{admin.id} a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(index_live, ~p"/admin/admins/#{admin}/edit")

      assert index_live
             |> form("#admin-form", admin: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/admins")
    end
  end
end
