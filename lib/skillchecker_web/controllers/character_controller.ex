defmodule SkillcheckerWeb.CharacterController do
  use SkillcheckerWeb, :controller

  alias Skillchecker.{Characters, Skillsets}

  def show(conn, %{"id" => id} = _params) do
    owner_hash = get_session(conn, :owner_hash)
    case Characters.get_character(id) do
      nil ->
        conn
        |> put_flash(:error, "To see this character's skills you need to login through EVE API with that character.")
        |> redirect(to: ~p"/")
        |> halt

      character ->
        if owner_hash != character.owner_hash do
          conn
          |> put_flash(:error, "To see this character's skills you need to login through EVE API with that character.")
          |> redirect(to: ~p"/")
          |> halt
        else
          skillsets = Skillsets.list_skillsets()

          case character.accepted do
            false ->
              conn
              |> redirect(to: ~p"/waiting/#{character}")
            true ->
              render conn, :show, character: character, skillsets: skillsets
          end
        end
    end
  end
end
