defmodule Skillchecker.CharactersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skillchecker.Characters` context.
  """

  alias Skillchecker.Characters
  alias Skillchecker.Repo

  @doc """
  Generate a character.
  """
  def character_fixture(attrs \\ %{}) do
    data = %{corporation: "Testwaffe", alliance: "GSF"}

    character =
      attrs
      |> Enum.into(%{
        accepted: true,
        eveid: 42,
        name: "Test Goon",
        owner_hash: "42zxc"
      })
      |> Characters.add_character()

    character
    |> Characters.change_character()
    |> Ecto.Changeset.put_embed(:data, data, [])
    |> Repo.update()

    character
  end

  def pending_character_fixture(attrs \\ %{}) do
    data = %{corporation: "Testwaffe", alliance: "GSF"}

    character =
      attrs
      |> Enum.into(%{
        accepted: false,
        eveid: 42,
        name: "Pending Goon",
        owner_hash: "42zxc42"
      })
      |> Characters.add_character()

    character
    |> Characters.change_character()
    |> Ecto.Changeset.put_embed(:data, data, [])
    |> Repo.update()

    character
  end

  def character_with_skills_fixture(attrs \\ %{}) do
    data = %{corporation: "Testwaffe", alliance: "GSF"}
    queued = [%{skill_id: 42, name: "Test Skill 1"}]
    trained = [%{skill_id: 60, name: "Test Skill 2", trained_level: 1}]

    character =
      attrs
      |> Enum.into(%{
        accepted: true,
        eveid: 42,
        name: "Test Goon",
        owner_hash: "42zxc"
      })
      |> Characters.add_character()

    character
    |> Characters.change_character()
    |> Ecto.Changeset.put_embed(:data, data, [])
    |> Ecto.Changeset.put_embed(:skill_queue, queued, [])
    |> Ecto.Changeset.put_embed(:skills, trained, [])
    |> Repo.update()

    character
  end
end
