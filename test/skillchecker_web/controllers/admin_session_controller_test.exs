defmodule SkillcheckerWeb.AdminSessionControllerTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Skillchecker.Factory

  defp setup_admins(_) do
    admin = insert(:admin, accepted: true)
    not_accepted = insert(:admin, accepted: false)

    %{not_accepted: not_accepted, admin: admin}
  end

  describe "POST /admins/log_in" do
    setup [:setup_admins]

    # test "logs the admin in if accepted", %{conn: conn, admin: admin} do
    #   conn =
    #     post(conn, ~p"/admin/log_in", %{
    #       "admin" => %{"name" => admin.name, "password" => "hello world!"}
    #     })

    #   assert get_session(conn, :admin_token)
    #   assert redirected_to(conn) == ~p"/admin/dashboard"

    #   # Now do a logged in request and assert on the menu
    #   conn = get(conn, ~p"/admin/dashboard")
    #   response = html_response(conn, 200)
    #   assert response =~ admin.name
    #   assert response =~ ~p"/admin/settings"
    #   assert response =~ ~p"/admin/log_out"
    # end

    # test "logs the admin in with remember me", %{conn: conn, admin: admin} do
    #   conn =
    #     post(conn, ~p"/admin/log_in", %{
    #       "admin" => %{
    #         "name" => admin.name,
    #         "password" => "hello world!",
    #         "remember_me" => "true"
    #       }
    #     })

    #   assert conn.resp_cookies["_skillchecker_web_admin_remember_me"]
    #   assert redirected_to(conn) == ~p"/admin/dashboard"
    # end

    # test "logs the admin in with return to", %{conn: conn, admin: admin} do
    #   conn =
    #     conn
    #     |> init_test_session(admin_return_to: "/foo/bar")
    #     |> post(~p"/admin/log_in", %{
    #       "admin" => %{
    #         "name" => admin.name,
    #         "password" => "hello world!"
    #       }
    #     })

    #   assert redirected_to(conn) == "/foo/bar"
    #   assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    # end

    # test "login following registration", %{conn: conn, admin: admin} do
    #   conn =
    #     post(conn, ~p"/admin/log_in", %{
    #       "_action" => "registered",
    #       "admin" => %{"name" => admin.name, "password" => "hello world!"}
    #     })

    #   assert redirected_to(conn) == ~p"/admin/dashboard"
    #   assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    # end

    # test "login following password update", %{conn: conn, admin: admin} do
    #   conn =
    #     post(conn, ~p"/admin/log_in", %{
    #       "_action" => "password_updated",
    #       "admin" => %{"name" => admin.name, "password" => "hello world!"}
    #     })

    #   assert redirected_to(conn) == ~p"/admin/settings"
    #   assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    # end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/admin/log_in", %{
          "admin" => %{"name" => "invalid@name.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid name or password"
      assert redirected_to(conn) == ~p"/admin/log_in"
    end
  end

  describe "DELETE /admins/log_out" do
    setup [:setup_admins]

    test "logs the admin out", %{conn: conn, admin: admin} do
      conn = conn |> log_in_admin(admin) |> delete(~p"/admin/log_out")

      assert redirected_to(conn) == ~p"/admin"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the admin is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/admin/log_out")

      assert redirected_to(conn) == ~p"/admin"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
