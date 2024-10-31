defmodule SkillcheckerWeb.SkillHelpersTest do
  use Skillchecker.DataCase

  import Skillchecker.CharactersFixtures
  import Skillchecker.SkillsetsFixtures
  import Skillchecker.StaticFixtures

  alias Skillchecker.Characters
  alias Skillchecker.Characters.Character
  alias Skillchecker.Skillsets.Skillset
  alias SkillcheckerWeb.SkillHelpers

  setup do
    %{
      calbs5: item_fixture(name: "Caldari Battleship", eveid: 1, skill_multiplier: 3),
      ambs5: item_fixture(name: "Amarr Battleship", eveid: 2),
      galbs5: item_fixture(name: "Gallente Battleship", eveid: 3)
    }
  end

  describe "non_gsf?/1" do
    test "GSF character returns false" do
      data = %{corporation: "Testwaffe", alliance: "GSF", alliance_id: 1_354_830_081}
      character = character_fixture()

      {:ok, character} =
        character
        |> Characters.change_character()
        |> Ecto.Changeset.put_embed(:data, data, [])
        |> Repo.update()

      assert SkillHelpers.non_gsf?(character) == false
    end

    test "other character returns false" do
      data = %{corporation: "Testwaffe", alliance: "GSF", alliance_id: 98_786}
      character = character_fixture()

      {:ok, character} =
        character
        |> Characters.change_character()
        |> Ecto.Changeset.put_embed(:data, data, [])
        |> Repo.update()

      assert SkillHelpers.non_gsf?(character) == true
    end
  end

  describe "display_skillset_name/1" do
    test "returns empty string if no skillset given" do
      assert SkillHelpers.display_skillset_name(nil) == ""
    end

    test "returns skillset's name if one is given" do
      skillset = skillset_fixture()

      assert SkillHelpers.display_skillset_name(skillset) == "some name"
    end
  end

  describe "display_skillset_completion/1" do
    test "returns empty string if no skillset given" do
      character = character_fixture()

      assert SkillHelpers.display_skillset_completion(nil, character.id) == ""
    end

    test "returns count if skillset and charater is given" do
      skillset = skillset_fixture()
      character = character_fixture()

      assert SkillHelpers.display_skillset_completion(skillset, character.id) == "0 / 2"
    end
  end

  describe "display_skill_points/1" do
    test "it humanizes the number" do
      assert SkillHelpers.display_skill_points(1_234_567_890) == "1.23 Billion"
    end

    test "it returns empty string if non-number passed" do
      assert SkillHelpers.display_skill_points("I'm not a number") == ""
    end
  end

  describe "display_skill_points_exact/1" do
    test "it delimits the number" do
      assert SkillHelpers.display_skill_points_exact(1_234_567_890) == "1,234,567,890"
    end

    test "it returns empty string if non-number passed" do
      assert SkillHelpers.display_skill_points_exact("I'm not a number") == ""
    end
  end

  describe "skill_training_disabled?/1" do
    test "returns true if no skill passed" do
      assert SkillHelpers.skill_training_disabled?(nil) == true
    end

    test "returns true if skill is not training" do
      skill = %Character.QueuedSkill{finish_date: nil}

      assert SkillHelpers.skill_training_disabled?(skill) == true
    end

    test "returns true if skill finished before now" do
      last_week = DateTime.add(DateTime.utc_now(), -7, :day)
      skill = %Character.QueuedSkill{finish_date: last_week}

      assert SkillHelpers.skill_training_disabled?(skill) == true
    end

    test "returns false if skill is training" do
      next_week = DateTime.add(DateTime.utc_now(), 7, :day)
      skill = %Character.QueuedSkill{finish_date: next_week}

      assert SkillHelpers.skill_training_disabled?(skill) == false
    end
  end

  describe "display_skillqueue_name/1" do
    test "returns message if nil passed" do
      assert SkillHelpers.display_skillqueue_name(nil) == "No skill queued."
    end

    test "returns skill name and training level" do
      skill = %Character.QueuedSkill{finished_level: 3, name: "Test Skill"}

      assert SkillHelpers.display_skillqueue_name(skill) == "Test Skill III"
    end
  end

  describe "display_skill_name/1" do
    test "returns message if nil passed" do
      assert SkillHelpers.display_skill_name(nil) == ""
    end

    test "returns skill name and trained level" do
      skill = %Character.Skill{trained_level: 2, name: "Test Skill"}

      assert SkillHelpers.display_skill_name(skill) == "Test Skill II"
    end
  end

  describe "display_skillset_skill_name/1" do
    test "returns message if nil passed" do
      assert SkillHelpers.display_skillset_skill_name(nil) == ""
    end

    test "returns skill name and required level" do
      skill = %Skillset.Skill{required_level: 2, name: "Test Skill"}

      assert SkillHelpers.display_skillset_skill_name(skill) == "Test Skill II"
    end
  end

  describe "display_skill_percent/1" do
    test "returns % of skill trained" do
      skill = %Character.QueuedSkill{
        finished_level: nil,
        name: "Test Skill",
        training_start_sp: 50,
        level_start_sp: 0,
        level_end_sp: 100
      }

      assert SkillHelpers.display_skill_percent(skill) == 50.0
    end

    test "returns zero if no skill passed" do
      assert SkillHelpers.display_skill_percent(nil) == 0
    end
  end

  describe "display_sp_left/1" do
    test "returns % of skill trained" do
      skill = %Character.QueuedSkill{
        finished_level: nil,
        name: "Test Skill",
        training_start_sp: 50,
        level_start_sp: 0,
        level_end_sp: 1000
      }

      assert SkillHelpers.display_sp_left(skill) == "950.00"
    end

    test "returns zero if no skill passed" do
      assert SkillHelpers.display_sp_left(nil) == 0.0
    end
  end

  describe "display_skill_time/1" do
    test "returns % of skill trained" do
      next_week = DateTime.add(DateTime.utc_now(), 7, :day)
      skill = %Character.QueuedSkill{finish_date: next_week}

      assert SkillHelpers.display_skill_time(skill) == "6 days, 23 hours, and 60 minutes"
    end

    test "returns empty string if skill is not training" do
      skill = %Character.QueuedSkill{finish_date: nil, name: "Test Skill"}
      assert SkillHelpers.display_skill_time(skill) == ""
    end

    test "returns empty string if no skill passed" do
      assert SkillHelpers.display_skill_time(nil) == ""
    end
  end

  describe "required_skill_sp/2" do
    test "shows how many sp the character still needs" do
      character = character_fixture()
      skills = [%Character.Skill{skill_id: 1, skill_points: 100}]
      skill = %Skillset.Skill{skill_id: 1, required_level: 3}

      {:ok, character} =
        character
        |> Characters.change_character()
        |> Ecto.Changeset.put_embed(:skills, skills, [])
        |> Repo.update()

      assert SkillHelpers.required_skill_sp(character, skill) == 23_900
    end

    test "character doesn't have the skill" do
      character = character_fixture()
      skill = %Skillset.Skill{skill_id: 1, required_level: 3}

      assert SkillHelpers.required_skill_sp(character, skill) == 24_000
    end
  end

  describe "display_skillset_required_sp/2" do
    test "shows how many sp the character still needs" do
      character = character_fixture()
      skills = [%Character.Skill{skill_id: 1, skill_points: 100}]
      skill = %Skillset.Skill{skill_id: 1, required_level: 3}

      {:ok, character} =
        character
        |> Characters.change_character()
        |> Ecto.Changeset.put_embed(:skills, skills, [])
        |> Repo.update()

      assert SkillHelpers.display_skillset_required_sp(character, skill) == "23 900"
    end
  end

  describe "display_skillset_trained_level/2" do
    test "shows how many sp the character still needs" do
      character = character_fixture()
      skills = [%Character.Skill{skill_id: 1, trained_level: 4}]
      skill = %Skillset.Skill{skill_id: 1, required_level: 5}

      {:ok, character} =
        character
        |> Characters.change_character()
        |> Ecto.Changeset.put_embed(:skills, skills, [])
        |> Repo.update()

      assert SkillHelpers.display_skillset_trained_level(character, skill) == "Trained level: IV"
    end

    test "character doesn't have the skill" do
      character = character_fixture()
      skill = %Skillset.Skill{skill_id: 1, required_level: 3}

      assert SkillHelpers.display_skillset_trained_level(character, skill) == "Not trained"
    end
  end
end
