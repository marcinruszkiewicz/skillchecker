defmodule Skillchecker.SkillsetsTest do
  use Skillchecker.DataCase
  alias Skillchecker.Skillsets
  alias Skillchecker.Skillsets.Skillset
  alias Skillchecker.Skillsets.Skillset.Skill

  import Skillchecker.SkillsetsFixtures
  import Skillchecker.StaticFixtures

  setup do
    %{
      calbs5: item_fixture(name: "Caldari Battleship", eveid: 1),
      ambs5: item_fixture(name: "Amarr Battleship", eveid: 2),
      galbs5: item_fixture(name: "Gallente Battleship", eveid: 3)
    }
  end

  describe "skillsets" do
    @invalid_attrs %{name: nil, skill_list: "Amarr Battleship V\nCaldari Battleship V"}

    test "list_skillsets/0 returns all skillsets" do
      skillset = skillset_fixture()
      assert_struct_in_list skillset, Skillsets.list_skillsets(), [:name, :skills]
    end

    test "get_skillset!/1 returns the skillset with given id" do
      skillset = skillset_fixture()
      assert_structs_equal skillset, Skillsets.get_skillset!(skillset.id), [:name, :skills]
    end

    test "create_skillset/1 with valid data creates a skillset" do
      valid_attrs = %{name: "some name", skill_list: "Amarr Battleship V\nCaldari Battleship V"}

      assert {:ok, %Skillset{} = skillset} = Skillsets.create_skillset(valid_attrs)
      assert skillset.name == "some name"
      assert [
        %Skill{name: "Amarr Battleship", required_level: 5},
        %Skill{name: "Caldari Battleship", required_level: 5}
      ] = skillset.skills

    end

    test "create_skillset/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skillsets.create_skillset(@invalid_attrs)
    end

    test "update_skillset/2 with valid data updates the skillset" do
      skillset = skillset_fixture()
      update_attrs = %{name: "some updated name", skill_list: "Gallente Battleship V"}

      assert {:ok, %Skillset{} = skillset} = Skillsets.update_skillset(skillset, update_attrs)
      assert skillset.name == "some updated name"
      assert [%Skill{name: "Gallente Battleship", required_level: 5}] = skillset.skills
    end

    test "update_skillset/2 with invalid data returns error changeset" do
      skillset = skillset_fixture()
      assert {:error, %Ecto.Changeset{}} = Skillsets.update_skillset(skillset, @invalid_attrs)
      assert skillset == Skillsets.get_skillset!(skillset.id)
    end

    test "delete_skillset/1 deletes the skillset" do
      skillset = skillset_fixture()
      assert {:ok, %Skillset{}} = Skillsets.delete_skillset(skillset)
      assert_raise Ecto.NoResultsError, fn -> Skillsets.get_skillset!(skillset.id) end
    end

    test "change_skillset/1 returns a skillset changeset" do
      skillset = skillset_fixture()
      assert %Ecto.Changeset{} = Skillsets.change_skillset(skillset)
    end
  end
end
