defmodule SkillcheckerWeb.CharacterControllerTest do
  use SkillcheckerWeb.ConnCase, async: true

  import Skillchecker.Factory

  describe "GET /character/:id" do
    test "without eve login it redirects to root", %{conn: conn} do
      conn = get(conn, ~p"/characters/1234")

      assert redirected_to(conn, 302) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "To see this character's skills you need to login through EVE API with that character."
    end

    test "with eve login but someone elses character", %{conn: conn} do
      character = insert(:character)

      conn =
        conn
        |> init_test_session(owner_hash: "completely wrong hash")
        |> get(~p"/characters/#{character.id}")

      assert redirected_to(conn, 302) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "To see this character's skills you need to login through EVE API with that character."
    end

    test "if character is logged in but not accepted it redirects to waiting page", %{conn: conn} do
      character = insert(:character, accepted: false)

      conn =
        conn
        |> init_test_session(owner_hash: character.owner_hash)
        |> get(~p"/characters/#{character.id}")

      assert redirected_to(conn, 302) == ~p"/waiting/#{character.id}"
    end

    test "if character is logged in and accepted shows info", %{conn: conn} do
      character = insert(:character)

      conn =
        conn
        |> init_test_session(owner_hash: character.owner_hash)
        |> get(~p"/characters/#{character.id}")

      assert response(conn, 200) =~ "Test Goon"
      assert response(conn, 200) =~ "Testwaffe"
    end
  end
end
