defmodule SkillcheckerWeb.CharacterLive.Refresh do
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Characters
  alias Skillchecker.Characters.{Character, CharacterSkills, CharacterData, RefreshToken}

  @impl true
  def render(_) do
    ""
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    character = Characters.get_character!(id)

    character = if Character.token_expired?(character) do
      {:ok, refreshed} = do_token_refresh(character)
      refreshed
    else
      character
    end

    do_character_refresh(socket, character)
  end

  defp do_character_refresh(socket, character) do
    character
    |> CharacterData.update_from_esi(character.token)
    |> CharacterSkills.update_from_esi(character.token)

    {:noreply, push_navigate(socket, to: ~p"/admin/characters/#{character}", replace: true)}
  rescue
    _ in RuntimeError ->
      {:noreply, push_navigate(socket, to: ~p"/admin/characters/#{character}", replace: true)}
  end

  defp do_token_refresh(character) do
    character
    |> RefreshToken.refresh_token
  end
end
