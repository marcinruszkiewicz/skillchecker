defmodule SkillcheckerWeb.AdminRegistrationLiveTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Skillchecker.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/admin/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_admin(admin_fixture())
        |> live(~p"/admin/register")
        |> follow_redirect(conn, "/admin/dashboard")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(admin: %{"name" => "with spaces", "password" => "too"})

      assert result =~ "Register"
      assert result =~ "should be at least 6 character"
    end
  end

  describe "register admin" do
    test "creates account and logs the admin in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin/register")

      name = unique_admin_name()
      form = form(lv, "#registration_form", admin: valid_admin_attributes(name: name))
      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/admin/dashboard"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admin/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/admin/log_in")

      assert login_html =~ "Log in"
    end
  end
end
