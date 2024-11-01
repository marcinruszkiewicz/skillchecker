defmodule SkillcheckerWeb.RequireAcceptedAdminTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Skillchecker.Factory

  alias Skillchecker.Accounts
  alias SkillcheckerWeb.RequireAcceptedAdmin

  setup %{conn: conn} do
    admin = insert(:admin, accepted: false)
    accepted = insert(:admin, accepted: true)

    conn =
      conn
      |> Map.replace!(:secret_key_base, SkillcheckerWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{accepted: accepted, admin: admin, conn: conn}
  end

  describe ".call" do
    test "returns the connection if admin is accepted", %{conn: conn, accepted: accepted} do
      admin_token = Accounts.generate_admin_session_token(accepted)

      conn =
        put_session(conn, :admin_token, admin_token)

      assert conn == RequireAcceptedAdmin.call(conn, %{})
    end

    test "redirects to waiting page if admin isn't accepted", %{conn: conn, admin: admin} do
      admin_token = Accounts.generate_admin_session_token(admin)

      conn =
        conn
        |> put_session(:admin_token, admin_token)
        |> fetch_flash()
        |> RequireAcceptedAdmin.call(%{})

      assert conn.halted
      assert redirected_to(conn) == "/admin/waiting"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "You need to be accepted to log in."
    end
  end
end
