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
end
