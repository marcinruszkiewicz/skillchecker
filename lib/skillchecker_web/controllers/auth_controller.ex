defmodule SkillcheckerWeb.AuthController do
  use SkillcheckerWeb, :controller

  alias Skillchecker.Characters
  alias Skillchecker.Characters.CharacterData
  alias Skillchecker.Characters.CharacterSkills

  plug Ueberauth

  def callback(conn, _params) do
    if owner_hash = get_session(conn, :owner_hash) do
      character = Skillchecker.Characters.get_character_by_owner_hash(owner_hash)

      redirect_to_character(conn, character)
    else
      attrs = %{
        eveid: conn.assigns.ueberauth_auth.extra.raw_info.user.character_id,
        name: conn.assigns.ueberauth_auth.extra.raw_info.user.name,
        owner_hash: conn.assigns.ueberauth_auth.extra.raw_info.user.owner_hash,
        token: conn.assigns.ueberauth_auth.credentials.token,
        refresh_token: conn.assigns.ueberauth_auth.credentials.refresh_token,
        expires_at: DateTime.from_unix!(conn.assigns.ueberauth_auth.credentials.expires_at, :second),
        accepted: false
      }

      character = Skillchecker.Characters.add_character(attrs)

      character
      |> Characters.update_refreshed!()
      |> CharacterData.update_from_esi(conn.assigns.ueberauth_auth.credentials.token)
      |> CharacterSkills.update_from_esi(conn.assigns.ueberauth_auth.credentials.token)

      conn =
        put_session(conn, :owner_hash, conn.assigns.ueberauth_auth.extra.raw_info.user.owner_hash)

      redirect_to_character(conn, character)
    end
  end

  defp redirect_to_character(conn, character) do
    if character.accepted do
      redirect(conn, to: ~p"/characters/#{character}")
    else
      redirect(conn, to: ~p"/waiting/#{character}")
    end
  end
end
