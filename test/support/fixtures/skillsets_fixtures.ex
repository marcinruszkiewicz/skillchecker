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
        skill_list: "Amarr Battleship V\nCaldari Battleship V"
      })
      |> Skillchecker.Skillsets.create_skillset()

    skillset
  end
end
