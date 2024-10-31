defmodule Skillchecker.Characters.CharacterSkills do
  @moduledoc """
  Wrapper for getting character skill data from the EVE API.
  """
  alias Skillchecker.Characters.Character
  alias Skillchecker.Repo

  def update_from_esi(character, token) do
    %{}
    |> get_skill_queue(character, token)
    |> get_skills(character, token)
    |> save_esi_data(character)
  end

  def save_esi_data(attrs, character) do
    result =
      character
      |> Character.changeset(%{})
      |> Ecto.Changeset.put_embed(:skill_queue, attrs[:queue], [])
      |> Ecto.Changeset.put_embed(:skills, attrs[:skills], [])
      |> Repo.update()

    {:ok, character} = result
    character
  end

  def get_skill_queue(attrs, character, token) do
    queue =
      character.eveid
      |> ESI.API.Character.skillqueue(token: token)
      |> ESI.request!()
      |> Enum.map(&prepare_skillqueue/1)

    Map.put(attrs, :queue, queue)
  end

  def get_skills(attrs, character, token) do
    data =
      character.eveid
      |> ESI.API.Character.skills(token: token)
      |> ESI.request!()

    skills =
      Enum.map(data["skills"], &prepare_skills/1)

    Map.put(attrs, :skills, skills)
  end

  defp atomize({k, v}) do
    {String.to_atom(k), v}
  end

  defp prepare_skillqueue(x) do
    map = Map.new(x, &atomize/1)

    Map.put(map, :name, Skillchecker.Static.get_item_name(map.skill_id))
  end

  defp prepare_skills(x) do
    map = Map.new(x, &atomize/1)

    map
    |> Map.put(:name, Skillchecker.Static.get_item_name(map.skill_id))
    |> Map.put(:group, Skillchecker.Static.get_group_name(map.skill_id))
    |> Map.put(:active_level, map.active_skill_level)
    |> Map.put(:trained_level, map.trained_skill_level)
    |> Map.put(:skill_points, map.skillpoints_in_skill)
    |> Map.drop([:skillpoints_in_skill, :active_skill_level, :trained_skill_level])
  end
end
