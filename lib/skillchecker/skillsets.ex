defmodule Skillchecker.Skillsets do
  @moduledoc """
  The Skillsets context.
  """

  import Ecto.Query, warn: false
  alias Skillchecker.Repo

  alias Skillchecker.Characters
  alias Skillchecker.Skillsets.Skillset

  @doc """
  Returns the list of skillsets.

  ## Examples

      iex> list_skillsets()
      [%Skillset{}, ...]

  """
  def list_skillsets do
    Skillset
    |> order_by([asc: :name])
    |> Repo.all()
  end

  @doc """
  Gets a single skillset.

  Raises `Ecto.NoResultsError` if the Skillset does not exist.

  ## Examples

      iex> get_skillset!(123)
      %Skillset{}

      iex> get_skillset!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skillset!(id), do: Repo.get!(Skillset, id)

  @doc """
  Creates a skillset.

  ## Examples

      iex> create_skillset(%{field: value})
      {:ok, %Skillset{}}

      iex> create_skillset(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skillset(attrs \\ %{}) do
    attrs = ExUtils.Map.symbolize_keys(attrs)
    skills = Skillset.prepare_skill_list(attrs.skill_list)

    %Skillset{}
    |> Skillset.changeset(attrs)
    |> Ecto.Changeset.put_embed(:skills, skills, [])
    |> Repo.insert()
  end

  @doc """
  Updates a skillset.

  ## Examples

      iex> update_skillset(skillset, %{field: new_value})
      {:ok, %Skillset{}}

      iex> update_skillset(skillset, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skillset(%Skillset{} = skillset, attrs) do
    attrs = ExUtils.Map.symbolize_keys(attrs)
    skills = Skillset.prepare_skill_list(attrs.skill_list)

    skillset
    |> Skillset.changeset(attrs)
    |> Ecto.Changeset.put_embed(:skills, skills, [])
    |> Repo.update()
  end

  @doc """
  Deletes a skillset.

  ## Examples

      iex> delete_skillset(skillset)
      {:ok, %Skillset{}}

      iex> delete_skillset(skillset)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skillset(%Skillset{} = skillset) do
    Repo.delete(skillset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skillset changes.

  ## Examples

      iex> change_skillset(skillset)
      %Ecto.Changeset{data: %Skillset{}}

  """
  def change_skillset(%Skillset{} = skillset, attrs \\ %{}) do
    Skillset.changeset(skillset, attrs)
  end

  def compare_with_character(id, character_id) do
    character = Characters.get_character!(character_id)

    {trained_skills, required_skills} =
      if id do
        get_trained_skills(character.skills, id)
      else
        {[], []}
      end
  end

  defp get_trained_skills(trained_skills, skillset_id) do
    skillset = get_skillset!(skillset_id)

    trained =
      skillset.skills
      |> Enum.filter(fn s -> trained_enough?(trained_skills, s) end)

    required =
      skillset.skills
      |> Enum.reject(fn s -> trained_enough?(trained_skills, s) end)

    {trained, required}
  end

  defp trained_enough?(trained_skills, skill) do
    trained_skill =
      trained_skills
      |> Enum.find(fn m -> m.skill_id == skill.skill_id end)

    if trained_skill do
      trained_skill.trained_level >= skill.required_level
    else
      false
    end
  end
end
