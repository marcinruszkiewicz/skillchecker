defmodule SkillcheckerWeb.AdminLiveTest do
  use SkillcheckerWeb.ConnCase

  import Skillchecker.Factory

  defp setup_admins(_) do
    admin = insert(:admin, accepted: true)
    not_accepted = insert(:admin, accepted: false)

    %{admin: admin, not_accepted: not_accepted}
  end

  describe "Index" do
    setup [:setup_admins]

    test "lists all admins", %{conn: conn, admin: admin} do
      conn
      |> log_in_admin(admin)
      |> visit(~p"/admin/admins")
      |> assert_has("h1", text: "Administrators")
      |> assert_has("td", text: admin.name)
    end

    test "updates admin in listing", %{conn: conn, admin: admin, not_accepted: not_accepted} do
      conn
      |> log_in_admin(admin)
      |> visit(~p"/admin/admins")
      |> within("tr#admins-#{not_accepted.id}", fn tr ->
        tr
        |> assert_has("td", text: "false")
        |> click_link("#admins-#{not_accepted.id} a", "Edit")
        |> within("#admin-form", fn form ->
          form
          |> check("Accepted")
          |> submit()
        end)
        |> assert_has("td", text: "true")
      end)
    end
  end
end
