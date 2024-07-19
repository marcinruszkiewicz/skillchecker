defmodule Skillchecker.SkillsetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skillchecker.Skillsets` context.
  """

  @doc """
  Generate a skillset.
  """
  def skillset_fixture(attrs \\ %{}) do
    {:ok, skillset} =
      attrs
      |> Enum.into(%{
        name: "some name",
        skills: "some skills"
      })
      |> Skillchecker.Skillsets.create_skillset()

    skillset
  end
end
