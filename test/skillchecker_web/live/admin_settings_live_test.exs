defmodule SkillcheckerWeb.AdminSettingsLiveTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Skillchecker.Factory

  alias Skillchecker.Accounts

  defp setup_admin(_) do
    admin = insert(:admin, accepted: true)

    %{admin: admin}
  end

  describe "Settings page" do
    setup [:setup_admin]

    test "renders settings page", %{conn: conn, admin: admin} do
      conn
      |> log_in_admin(admin)
      |> visit(~p"/admin/settings")
      |> assert_has("h1", text: "Account Settings")
    end

    test "redirects if admin is not logged in", %{conn: conn} do
      conn
      |> visit(~p"/admin/settings")
      |> assert_path(~p"/admin/log_in")
    end
  end

  describe "update password form" do
    setup [:setup_admin]

    test "updates the admin password", %{conn: conn, admin: admin} do
      conn
      |> log_in_admin(admin)
      |> visit(~p"/admin/settings")
      |> fill_in("Current password", with: "greatest password!")
      |> fill_in("New password", with: "super password!")
      |> fill_in("Confirm new password", with: "super password!")
      |> submit()

      assert Accounts.get_admin_by_name_and_password(admin.name, "super password!")
    end

    test "renders errors with invalid data", %{conn: conn, admin: admin} do
      conn
      |> log_in_admin(admin)
      |> visit(~p"/admin/settings")
      |> fill_in("Current password", with: "invalid")
      |> fill_in("New password", with: "123")
      |> fill_in("Confirm new password", with: "not so super password!")
      |> submit()
      |> assert_has("p", text: "should be at least 6 character(s)")
      |> assert_has("p", text: "does not match password")
    end
  end
end
