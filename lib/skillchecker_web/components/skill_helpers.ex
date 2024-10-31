defmodule SkillcheckerWeb.SkillHelpers do
  @moduledoc """
  Display helpers for skills and skill points.
  """
  alias Skillchecker.Cldr
  alias Skillchecker.Skillsets
  alias Skillchecker.Static

  def non_gsf?(character) do
    # magic number of GSF in the ESI data. This is saved in the Eve Online data and will never change.
    character.data.alliance_id != 1_354_830_081
  end

  def display_skillset_name(nil), do: ""
  def display_skillset_name(skillset), do: skillset.name

  def display_skillset_completion(nil, _), do: ""

  def display_skillset_completion(skillset, character_id) do
    {trained_skills, _} = Skillsets.compare_with_character(skillset.id, character_id)
    max_skills = Enum.count(skillset.skills)
    completed_skills = Enum.count(trained_skills)

    "#{completed_skills} / #{max_skills}"
  end

  def display_skill_points(num) when is_number(num), do: Number.Human.number_to_human(num)
  def display_skill_points(_), do: ""

  def display_skill_points_exact(num) when is_number(num), do: Number.Delimit.number_to_delimited(num, precision: 0)
  def display_skill_points_exact(_), do: ""

  def skill_training_disabled?(nil), do: true

  def skill_training_disabled?(skill) do
    cond do
      skill.finish_date == nil ->
        true

      DateTime.diff(skill.finish_date, DateTime.utc_now()) < 0 ->
        true

      true ->
        false
    end
  end

  def display_skillqueue_name(nil), do: "No skill queued."

  def display_skillqueue_name(skill) do
    "#{skill.name} #{RomanNumerals.convert(skill.finished_level)}"
  end

  def display_skill_percent(nil), do: 0.0

  def display_skill_percent(skill) do
    sp_in_skill = skill.training_start_sp - skill.level_start_sp

    Float.round(100 * sp_in_skill / skill.level_end_sp, 2)
  end

  def display_sp_left(nil), do: 0.0

  def display_sp_left(skill) do
    sp_in_skill = skill.training_start_sp - skill.level_start_sp
    Number.Human.number_to_human(skill.level_end_sp - sp_in_skill)
  end

  def display_skill_time(nil), do: ""
  def display_skill_time(skill) when is_nil(skill.finish_date), do: ""

  def display_skill_time(skill) do
    skill.finish_date
    |> DateTime.diff(DateTime.utc_now(), :microsecond)
    |> Cldr.Unit.new!(:microsecond)
    |> Cldr.Unit.decompose([:day, :hour, :minute])
    |> Cldr.Unit.to_string()
    |> do_display_skill_time()
  end

  defp do_display_skill_time({:ok, string}), do: string

  def display_skill_name(nil), do: ""

  def display_skill_name(skill) do
    "#{skill.name} #{RomanNumerals.convert(skill.trained_level)}"
  end

  def display_skillset_skill_name(nil), do: ""

  def display_skillset_skill_name(skill) do
    "#{skill.name} #{RomanNumerals.convert(skill.required_level)}"
  end

  def display_skillset_trained_level(character, skill) do
    trained_skill =
      Enum.find(character.skills, fn m -> m.skill_id == skill.skill_id end)

    if trained_skill do
      "Trained level: #{RomanNumerals.convert(trained_skill.trained_level)}"
    else
      "Not trained"
    end
  end

  def required_skill_sp(character, skill) do
    trained_skill =
      Enum.find(character.skills, fn m -> m.skill_id == skill.skill_id end)

    multiplier = Static.get_skill_multiplier(skill.skill_id)

    required_sp =
      round(250 * multiplier * :math.sqrt(:math.pow(32, skill.required_level - 1)))

    sp_in_skill =
      if trained_skill do
        trained_skill.skill_points
      else
        0
      end

    required_sp - sp_in_skill
  end

  def display_skillset_required_sp(character, skill) do
    character
    |> required_skill_sp(skill)
    |> Number.Delimit.number_to_delimited(precision: 0, delimiter: " ")
  end
end
