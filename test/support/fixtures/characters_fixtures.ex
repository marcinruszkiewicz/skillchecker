defmodule Skillchecker.CharactersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skillchecker.Characters` context.
  """

  alias Skillchecker.Repo
  alias Skillchecker.Characters

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
        owner_hash: "42zxc",
      })
      |> Characters.add_character()


      character
      |> Characters.change_character()
      |> Ecto.Changeset.put_embed(:data, data, [])
      |> Repo.update

    character
  end
end
