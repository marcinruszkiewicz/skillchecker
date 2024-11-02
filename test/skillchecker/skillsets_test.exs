defmodule Skillchecker.SkillsetsTest do
  use Skillchecker.DataCase

  import Assertions
  import Skillchecker.Factory

  alias Skillchecker.Skillsets
  alias Skillchecker.Skillsets.Skillset
  alias Skillchecker.Skillsets.Skillset.Skill

  defp prepare_skills(_) do
    insert(:item, name: "Caldari Battleship", eveid: 1)
    insert(:item, name: "Amarr Battleship", eveid: 2)
    insert(:item, name: "Gallente Battleship", eveid: 3)
    skillset_params = params_for(:skillset)
    {:ok, skillset} = Skillsets.create_skillset(skillset_params)

    %{skillset: skillset}
  end

  @invalid_attrs %{name: nil, skill_list: "Amarr Battleship V\nCaldari Battleship"}

  describe "list_skillsets/0" do
    setup [:prepare_skills]

    test "returns all skillsets", %{skillset: skillset} do
      assert_struct_in_list(skillset, Skillsets.list_skillsets(), [:name, :skills])
    end
  end

  describe "get_skillset!/1" do
    setup [:prepare_skills]

    test "returns the skillset with given id", %{skillset: skillset} do
      assert_structs_equal(skillset, Skillsets.get_skillset!(skillset.id), [:name, :skills])
    end
  end

  describe "create_skillset/1" do
    setup [:prepare_skills]

    test "with valid data creates a skillset" do
      valid_attrs = %{name: "some name", skill_list: "Amarr Battleship V\nCaldari Battleship 5"}
      {:ok, skillset} = Skillsets.create_skillset(valid_attrs)

      assert_structs_equal(
        %Skillset{
          name: "some name"
        },
        skillset,
        [:name]
      )

      assert_struct_in_list(
        %Skill{name: "Caldari Battleship", required_level: 5},
        skillset.skills,
        [:name, :required_level]
      )

      assert_struct_in_list(
        %Skill{name: "Amarr Battleship", required_level: 5},
        skillset.skills,
        [:name, :required_level]
      )
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skillsets.create_skillset(@invalid_attrs)
    end

    test "with empty skill list creates a skillset" do
      valid_attrs = %{name: "some name", skill_list: nil}
      {:ok, skillset} = Skillsets.create_skillset(valid_attrs)

      assert_structs_equal(
        %Skillset{
          name: "some name",
          skills: []
        },
        skillset,
        [:name, :skills]
      )
    end
  end

  describe "update_skillset/2" do
    setup [:prepare_skills]

    test "with valid data updates the skillset", %{skillset: skillset} do
      update_attrs = %{name: "some updated name", skill_list: "Gallente Battleship V"}
      {:ok, updated} = Skillsets.update_skillset(skillset, update_attrs)

      assert_structs_equal(
        %Skillset{
          name: "some updated name"
        },
        updated,
        [:name]
      )

      assert_struct_in_list(
        %Skill{name: "Gallente Battleship", required_level: 5},
        updated.skills,
        [:name, :required_level]
      )
    end

    test "with invalid data returns error changeset", %{skillset: skillset} do
      assert {:error, %Ecto.Changeset{}} = Skillsets.update_skillset(skillset, @invalid_attrs)

      assert_structs_equal(
        %Skillset{
          name: "L Combat"
        },
        skillset,
        [:name]
      )
    end
  end

  describe "delete_skillset/1" do
    setup [:prepare_skills]

    test "deletes the skillset", %{skillset: skillset} do
      assert {:ok, %Skillset{}} = Skillsets.delete_skillset(skillset)
      assert_raise Ecto.NoResultsError, fn -> Skillsets.get_skillset!(skillset.id) end
    end
  end

  describe "change_skillset/1" do
    setup [:prepare_skills]

    test "returns a skillset changeset", %{skillset: skillset} do
      assert %Ecto.Changeset{} = Skillsets.change_skillset(skillset)
    end
  end

  describe "compare_with_character/2" do
    setup [:prepare_skills]

    test "with not existing skillset id returns empty arrays" do
      character = insert(:character_with_skills)
      assert {[], []} = Skillsets.compare_with_character(9876, character.id)
    end

    test "with not existing character id returns empty arrays", %{skillset: skillset} do
      assert {[], []} = Skillsets.compare_with_character(skillset.id, 8766)
    end

    test "with both existing returns missing skills", %{skillset: skillset} do
      character =
        insert(:character, skills: [%{skill_id: 1, name: "Caldari Battleship", trained_level: 5, active_level: 5}])

      assert {trained, missing} = Skillsets.compare_with_character(skillset.id, character.id)
      assert_struct_in_list(%Skill{name: "Amarr Battleship", required_level: 5}, missing, [:name, :required_level])
      assert_struct_in_list(%Skill{name: "Caldari Battleship", required_level: 5}, trained, [:name, :required_level])
    end
  end
end
