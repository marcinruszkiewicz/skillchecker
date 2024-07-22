defmodule Skillchecker.Characters do
  @moduledoc """
  The Characters context.
  """

  import Ecto.Query, warn: false
  alias Skillchecker.Repo

  alias Skillchecker.Characters.Character

  @doc """
  Returns the list of characters.

  ## Examples

      iex> list_characters()
      [%Character{}, ...]

  """
  def list_characters do
    Repo.all(Character)
  end

  @doc """
  Returns the list of characters.

  ## Examples

      iex> list_pending_characters()
      [%Character{}, ...]

  """
  def list_pending_characters do
    Character
    |> where(accepted: false)
    |> Repo.all()
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!(123)
      %Character{}

      iex> get_character!(456)
      ** (Ecto.NoResultsError)

  """
  def get_character!(id), do: Repo.get!(Character, id)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character changes.

  ## Examples

      iex> change_character(character)
      %Ecto.Changeset{data: %Character{}}

  """
  def change_character(%Character{} = character, attrs \\ %{}) do
    Character.changeset(character, attrs)
  end

  def add_character(%{owner_hash: owner_hash} = attrs \\ %{}) do
    existing = get_character_by_owner_hash(owner_hash)

    case existing do
      nil ->
        insert_character(attrs)
      %Character{} ->
        existing
    end
  end

  def get_character_by_owner_hash(owner_hash) do
    Repo.get_by(Character, owner_hash: owner_hash)
  end

  defp insert_character(attrs) do
    character =
      %Character{}
      |> Character.changeset(attrs)
      |> Repo.insert()

    case character do
      {:ok, character} ->
        character
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end
end
