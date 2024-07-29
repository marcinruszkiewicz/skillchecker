defmodule Skillchecker.SkillsetsTest do
  use Skillchecker.DataCase
  alias Skillchecker.Skillsets
  alias Skillchecker.Characters
  alias Skillchecker.Skillsets.Skillset
  alias Skillchecker.Skillsets.Skillset.Skill

  import Skillchecker.SkillsetsFixtures
  import Skillchecker.StaticFixtures
  import Skillchecker.CharactersFixtures

  setup do
    %{
      calbs5: item_fixture(name: "Caldari Battleship", eveid: 1),
      ambs5: item_fixture(name: "Amarr Battleship", eveid: 2),
      galbs5: item_fixture(name: "Gallente Battleship", eveid: 3)
    }
  end

  @invalid_attrs %{name: nil, skill_list: "Amarr Battleship V\nCaldari Battleship"}

  describe "list_skillsets/0" do
    test "returns all skillsets" do
      skillset = skillset_fixture()
      assert_struct_in_list skillset, Skillsets.list_skillsets(), [:name, :skills]
    end
  end

  describe "get_skillset!/1" do
    test "returns the skillset with given id" do
      skillset = skillset_fixture()
      assert_structs_equal skillset, Skillsets.get_skillset!(skillset.id), [:name, :skills]
    end
  end

  describe "create_skillset/1" do
    test "with valid data creates a skillset" do
      valid_attrs = %{name: "some name", skill_list: "Amarr Battleship V\nCaldari Battleship 5"}

      assert {:ok, %Skillset{} = skillset} = Skillsets.create_skillset(valid_attrs)
      assert skillset.name == "some name"
      assert [
        %Skill{name: "Amarr Battleship", required_level: 5},
        %Skill{name: "Caldari Battleship", required_level: 5}
      ] = skillset.skills
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skillsets.create_skillset(@invalid_attrs)
    end

    test "with empty skill list creates a skillset" do
      valid_attrs = %{name: "some name", skill_list: nil}

      assert {:ok, %Skillset{} = skillset} = Skillsets.create_skillset(valid_attrs)
      assert skillset.name == "some name"
      assert [] = skillset.skills
    end
  end

  describe "update_skillset/2" do
    test "with valid data updates the skillset" do
      skillset = skillset_fixture()
      update_attrs = %{name: "some updated name", skill_list: "Gallente Battleship V"}

      assert {:ok, %Skillset{} = skillset} = Skillsets.update_skillset(skillset, update_attrs)
      assert skillset.name == "some updated name"
      assert [%Skill{name: "Gallente Battleship", required_level: 5}] = skillset.skills
    end

    test "with invalid data returns error changeset" do
      skillset = skillset_fixture()
      assert {:error, %Ecto.Changeset{}} = Skillsets.update_skillset(skillset, @invalid_attrs)
      assert skillset == Skillsets.get_skillset!(skillset.id)
    end
  end

  describe "delete_skillset/1" do
    test "deletes the skillset" do
      skillset = skillset_fixture()
      assert {:ok, %Skillset{}} = Skillsets.delete_skillset(skillset)
      assert_raise Ecto.NoResultsError, fn -> Skillsets.get_skillset!(skillset.id) end
    end
  end

  describe "change_skillset/1" do
    test "returns a skillset changeset" do
      skillset = skillset_fixture()
      assert %Ecto.Changeset{} = Skillsets.change_skillset(skillset)
    end
  end

  describe "compare_with_character/2" do
    test "with not existing skillset id returns empty arrays" do
      character = character_with_skills_fixture()
      assert {[], []} = Skillsets.compare_with_character(9876, character.id)
    end

    test "with not existing character id returns empty arrays" do
      skillset = skillset_fixture()
      assert {[], []} = Skillsets.compare_with_character(skillset.id, 8766)
    end

    test "with both existing returns missing skills" do
      character = character_fixture()
      skillset = skillset_fixture()
      trained = [
        %{skill_id: 1, name: "Caldari Battleship", trained_level: 5, active_level: 5}
      ]

      {:ok, character} =
        character
        |> Characters.change_character()
        |> Ecto.Changeset.put_embed(:skills, trained, [])
        |> Repo.update

      assert {trained, missing} = Skillsets.compare_with_character(skillset.id, character.id)

      assert_struct_in_list %Skill{name: "Amarr Battleship", required_level: 5}, missing, [:name, :required_level]
      assert_struct_in_list %Skill{name: "Caldari Battleship", required_level: 5}, trained, [:name, :required_level]
    end
  end
end
