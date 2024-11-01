defmodule SkillcheckerWeb.AdminRegistrationLiveTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Assertions
  import Skillchecker.Factory

  alias Skillchecker.Accounts
  alias Skillchecker.Accounts.Admin

  defp setup_admins(_) do
    admin = insert(:admin, accepted: true)
    not_accepted = insert(:admin, accepted: false)

    %{admin: admin, not_accepted: not_accepted}
  end

  describe "Registration page" do
    setup [:setup_admins]

    test "renders registration page", %{conn: conn} do
      conn
      |> visit(~p"/admin/register")
      |> assert_has("h1", text: "Register for an account")
    end

    test "redirects if already logged in", %{conn: conn, admin: admin} do
      conn
      |> log_in_admin(admin)
      |> visit(~p"/admin/register")
      |> assert_path(~p"/admin/dashboard")
    end

    test "renders errors for invalid data", %{conn: conn} do
      conn
      |> visit(~p"/admin/register")
      |> within("#registration_form", fn form ->
        form
        |> fill_in("Name", with: "it's a name")
        |> fill_in("Password", with: "123")
        |> submit()
      end)
      |> assert_has("p", text: "should be at least 6 character")
    end
  end

  describe "register admin" do
    test "creates account", %{conn: conn} do
      conn
      |> visit(~p"/admin/register")
      |> within("#registration_form", fn form ->
        form
        |> fill_in("Name", with: "my_name")
        |> fill_in("Password", with: "cool password!")
        |> submit()
      end)

      assert_structs_equal(%Admin{name: "my_name", accepted: false}, Accounts.get_admin_by_name("my_name"), [
        :name,
        :accepted
      ])
    end
  end
end
