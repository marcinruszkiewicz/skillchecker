defmodule SkillcheckerWeb.CharacterLive.Refresh do
  @moduledoc false
  use SkillcheckerWeb, :live_view

  alias Skillchecker.Characters
  alias Skillchecker.Characters.Character
  alias Skillchecker.Characters.CharacterData
  alias Skillchecker.Characters.CharacterSkills
  alias Skillchecker.Characters.RefreshToken

  @impl true
  def render(assigns), do: ~H""

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    character = Characters.get_character!(id)

    character =
      if Character.token_expired?(character) do
        {:ok, refreshed} = do_token_refresh(character)
        refreshed
      else
        character
      end

    do_character_refresh(socket, character)
  end

  defp do_character_refresh(socket, character) do
    character
    |> Characters.update_refreshed!()
    |> CharacterData.update_from_esi(character.token)
    |> CharacterSkills.update_from_esi(character.token)

    {:noreply, push_navigate(socket, to: ~p"/admin/characters/#{character}", replace: true)}
  rescue
    _ in RuntimeError ->
      {:noreply, push_navigate(socket, to: ~p"/admin/characters/#{character}", replace: true)}
  end

  defp do_token_refresh(character) do
    RefreshToken.refresh_token(character)
  end
end
