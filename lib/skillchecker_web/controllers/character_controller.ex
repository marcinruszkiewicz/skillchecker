defmodule SkillcheckerWeb.CharacterController do
  use SkillcheckerWeb, :controller

  alias Skillchecker.Characters
  alias Skillchecker.Skillsets

  def show(conn, %{"id" => id} = _params) do
    owner_hash = get_session(conn, :owner_hash)

    case Characters.get_character(id) do
      nil ->
        conn
        |> put_flash(:error, "To see this character's skills you need to login through EVE API with that character.")
        |> redirect(to: ~p"/")
        |> halt()

      character ->
        if owner_hash == character.owner_hash do
          skillsets = Skillsets.list_skillsets_for_character(character)

          if character.accepted do
            render(conn, :show, character: character, skillsets: skillsets)
          else
            redirect(conn, to: ~p"/waiting/#{character}")
          end
        else
          conn
          |> put_flash(:error, "To see this character's skills you need to login through EVE API with that character.")
          |> redirect(to: ~p"/")
          |> halt()
        end
    end
  end
end
