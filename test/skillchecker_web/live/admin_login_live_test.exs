defmodule SkillcheckerWeb.AdminLoginLiveTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Skillchecker.Factory

  defp setup_admins(_) do
    admin = insert(:admin, accepted: true, name: "My Name")
    not_accepted = insert(:admin, accepted: false, name: "Waiting")

    %{admin: admin, not_accepted: not_accepted}
  end

  describe "Log in page" do
    setup [:setup_admins]

    test "renders log in page", %{conn: conn} do
      conn
      |> visit(~p"/admin/log_in")
      |> assert_has("h1", text: "Log in to account")
    end

    test "redirects if already logged in", %{conn: conn, admin: admin} do
      conn
      |> log_in_admin(admin)
      |> visit(~p"/admin/log_in")
      |> assert_path(~p"/admin/dashboard")
    end
  end

  describe "admin login" do
    setup [:setup_admins]

    test "redirects if admin login with valid credentials", %{conn: conn} do
      conn
      |> visit(~p"/admin/log_in")
      |> assert_has("h1", text: "Log in to account")
      |> within("#login_form", fn form ->
        form
        |> fill_in("Name", with: "My Name")
        |> fill_in("Password", with: "greatest password!")
        |> submit()
      end)
      |> assert_path(~p"/admin/dashboard")
    end

    test "redirects to login page if login invalid", %{conn: conn} do
      conn
      |> visit(~p"/admin/log_in")
      |> assert_has("h1", text: "Log in to account")
      |> within("#login_form", fn form ->
        form
        |> fill_in("Name", with: "wrong")
        |> fill_in("Password", with: "this is wrong too")
        |> submit()
      end)
      |> assert_path(~p"/admin/log_in")
    end
  end

  describe "admin not accepted yet" do
    setup [:setup_admins]

    test "redirects to waiting page if login is valid", %{conn: conn} do
      conn
      |> visit(~p"/admin/log_in")
      |> assert_has("h1", text: "Log in to account")
      |> within("#login_form", fn form ->
        form
        |> fill_in("Name", with: "Waiting")
        |> fill_in("Password", with: "greatest password!")
        |> submit()
      end)
      |> assert_path(~p"/admin/waiting")
      |> assert_has("p", text: "You need to be accepted to log in.")
    end
  end
end
