defmodule SkillcheckerWeb.PageControllerTest do
  use SkillcheckerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~ "Log in with your Eve character"
  end

  test "GET /admin", %{conn: conn} do
    conn = get(conn, ~p"/admin")

    assert html_response(conn, 200) =~ "GSF Alliance Tournament Skill Checker"
    refute html_response(conn, 200) =~ "Log in with your Eve character"
  end

  test "GET /admin/waiting", %{conn: conn} do
    conn = get(conn, ~p"/admin/waiting")

    assert html_response(conn, 200) =~ "GSF Alliance Tournament Skill Checker"
    assert html_response(conn, 200) =~ "You need to be accepted to log in."
    refute html_response(conn, 200) =~ "Log in with your Eve character"
  end

  test "GET /waiting/:character_id", %{conn: conn} do
    conn = get(conn, ~p"/waiting/1322")

    assert html_response(conn, 200) =~ "GSF Alliance Tournament Skill Checker"
    assert html_response(conn, 200) =~ "Your character needs to be accepted by the admins first."
    refute html_response(conn, 200) =~ "Log in with your Eve character"
  end
end
