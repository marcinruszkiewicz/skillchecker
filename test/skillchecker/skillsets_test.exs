defmodule Skillchecker.SkillsetsTest do
  use Skillchecker.DataCase

  alias Skillchecker.Skillsets

  describe "skillsets" do
    alias Skillchecker.Skillsets.Skillset

    import Skillchecker.SkillsetsFixtures

    @invalid_attrs %{name: nil, skills: nil}

    test "list_skillsets/0 returns all skillsets" do
      skillset = skillset_fixture()
      assert Skillsets.list_skillsets() == [skillset]
    end

    test "get_skillset!/1 returns the skillset with given id" do
      skillset = skillset_fixture()
      assert Skillsets.get_skillset!(skillset.id) == skillset
    end

    test "create_skillset/1 with valid data creates a skillset" do
      valid_attrs = %{name: "some name", skills: "some skills"}

      assert {:ok, %Skillset{} = skillset} = Skillsets.create_skillset(valid_attrs)
      assert skillset.name == "some name"
      assert skillset.skills == "some skills"
    end

    test "create_skillset/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skillsets.create_skillset(@invalid_attrs)
    end

    test "update_skillset/2 with valid data updates the skillset" do
      skillset = skillset_fixture()
      update_attrs = %{name: "some updated name", skills: "some updated skills"}

      assert {:ok, %Skillset{} = skillset} = Skillsets.update_skillset(skillset, update_attrs)
      assert skillset.name == "some updated name"
      assert skillset.skills == "some updated skills"
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
