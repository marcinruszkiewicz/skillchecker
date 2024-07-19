defmodule Skillchecker.CharactersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skillchecker.Characters` context.
  """

  @doc """
  Generate a character.
  """
  def character_fixture(attrs \\ %{}) do
    {:ok, character} =
      attrs
      |> Enum.into(%{
        accepted: true,
        eveid: 42,
        name: "some name"
      })
      |> Skillchecker.Characters.create_character()

    character
  end
end
