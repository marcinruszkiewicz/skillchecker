defmodule SkillcheckerWeb.PageController do
  use SkillcheckerWeb, :controller

  def user_landing(conn, _params) do
    if owner_hash = get_session(conn, :owner_hash) do
      character = Skillchecker.Characters.get_character_by_owner_hash(owner_hash)

      redirect_to_character(conn, character)
    else
      render conn, :user_landing, layout: false
    end
  end

  def admin_landing(conn, _params) do
    render conn, :admin_landing, layout: false
  end

  def admin_waiting(conn, _params) do
    render conn, :admin_waiting, layout: false
  end

  def user_waiting(conn, %{"id" => id} = _params) do
    render conn, :user_waiting, layout: false, id: id
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
