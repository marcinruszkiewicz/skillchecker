defmodule Skillchecker.Skillsets.Skillset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skillsets" do
    field :name, :string

    embeds_many :skills, Skill, on_replace: :delete do
      field :skill_id, :integer
      field :name, :string
      field :required_level, :integer
    end

    timestamps()
  end

  @doc false
  def changeset(skillset, attrs) do
    skillset
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc """
  Transform a list of skills from a text list into a map of skills that can be saved in the database.

  ## Examples

      iex> Skillchecker.Static.create_item(%Skillchecker.Static.Item{name: "Gallente Frigate", eveid: 1234, groupid: 1})
      iex> Skillchecker.Skillsets.Manual.prepare_skill_list("Gallente Frigate 3")
      [%{name: "Gallente Frigate", required_level: 3, skill_id: 1234}]

      iex> Skillchecker.Static.create_item(%Skillchecker.Static.Item{name: "Caldari Frigate", eveid: 1234, groupid: 1})
      iex> Skillchecker.Skillsets.Manual.prepare_skill_list("Caldari Frigate III")
      [%{name: "Caldari Frigate", required_level: 3, skill_id: 1234}]

      iex> Skillchecker.Static.create_item(%Skillchecker.Static.Item{name: "Amarr Frigate", eveid: 1234, groupid: 1})
      iex> Skillchecker.Skillsets.Manual.prepare_skill_list("Amarr   Frigate    3")
      [%{name: "Amarr Frigate", required_level: 3, skill_id: 1234}]
  """
  def prepare_skill_list(skills_string) do
    skills_string
    |> String.replace("\r", "")
    |> String.split("\n")
    |> Enum.uniq
    |> Enum.filter(fn x -> if(x != "") do x end end)
    |> Enum.map(&prepare_skill_struct/1)
  end

  defp prepare_skill_struct(skill) do
    {level, name_list} =
      skill
      |> String.split(" ", trim: true)
      |> List.pop_at(-1)

    name =
      name_list
      |> Enum.join(" ")
      |> String.trim_leading
      |> String.trim_trailing

    id = Skillchecker.Static.find_item_eveid(name)

    if id do
      %{
        required_level: decode_level(level),
        name: name,
        skill_id: id
      }
    end
  end

  defp decode_level(nil), do: nil
  defp decode_level(string) do
    case Integer.parse(string) do
      :error ->
        RomanNumerals.to_num(string)
      {num, _} ->
        num
    end
  end

  def export_skill_list(skills_map) do
    skills_map
    |> Enum.map(&join_skill_name/1)
    |> Enum.join("\r\n")
  end

  defp join_skill_name(skill) do
    "#{skill.name} #{RomanNumerals.convert(skill.required_level)}"
  end
end
