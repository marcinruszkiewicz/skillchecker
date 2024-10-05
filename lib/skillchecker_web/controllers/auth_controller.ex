defmodule SkillcheckerWeb.AuthController do
  use SkillcheckerWeb, :controller

  plug Ueberauth

  alias Skillchecker.Characters.CharacterData
  alias Skillchecker.Characters.CharacterSkills

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
        expires_at: conn.assigns.ueberauth_auth.credentials.expires_at |> DateTime.from_unix!(:second),
        accepted: false
      }

      character = Skillchecker.Characters.add_character(attrs)

      character
      |> CharacterData.update_from_esi(conn.assigns.ueberauth_auth.credentials.token)
      |> CharacterSkills.update_from_esi(conn.assigns.ueberauth_auth.credentials.token)

      conn =
        conn
        |> put_session(:owner_hash, conn.assigns.ueberauth_auth.extra.raw_info.user.owner_hash)

      redirect_to_character(conn, character)
    end
  end

  defp redirect_to_character(conn, character) do
    case character.accepted do
      false ->
        conn
        |> redirect(to: ~p"/waiting/#{character}")
      true ->
        conn
        |> redirect(to: ~p"/characters/#{character}")
    end
  end
end
