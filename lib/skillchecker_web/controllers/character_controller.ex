defmodule SkillcheckerWeb.CharacterController do
  use SkillcheckerWeb, :controller

  alias Skillchecker.{Characters, Skillsets}

  def show(conn, %{"id" => id} = params) do
    character = Characters.get_character!(id)
    skillsets = Skillsets.list_skillsets()

    case character.accepted do
      false ->
        conn
        |> redirect(to: ~p"/waiting")
      true ->
        render conn, :show, layout: false, character: character, skillsets: skillsets
    end
  end
end