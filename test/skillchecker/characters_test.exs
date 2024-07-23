defmodule Skillchecker.CharactersTest do
  use Skillchecker.DataCase

  alias Skillchecker.Characters
  alias Skillchecker.Characters.Character
  import Skillchecker.CharactersFixtures

  describe "characters" do
    @invalid_attrs %{name: nil, eveid: nil, accepted: nil, owner_hash: nil}

    test "list_characters/0 returns all characters" do
      character = character_fixture()
      assert_struct_in_list character, Characters.list_characters, [:eveid, :name, :owner_hash]
    end

    test "get_character!/1 returns the character with given id" do
      character = character_fixture()
      assert_structs_equal character, Characters.get_character!(character.id), [:eveid, :name, :owner_hash]
    end

    test "update_character/2 with valid data updates the character" do
      character = character_fixture()
      update_attrs = %{name: "some updated name", eveid: 43, accepted: false, owner_hash: "123"}

      assert {:ok, %Character{} = character} = Characters.update_character(character, update_attrs)
      assert character.name == "some updated name"
      assert character.eveid == 43
      assert character.accepted == false
    end

    test "update_character/2 with invalid data returns error changeset" do
      character = character_fixture()
      assert {:error, %Ecto.Changeset{}} = Characters.update_character(character, @invalid_attrs)
      assert_structs_equal character, Characters.get_character!(character.id), [:eveid, :name, :owner_hash]
    end

    test "change_character/1 returns a character changeset" do
      character = character_fixture()
      assert %Ecto.Changeset{} = Characters.change_character(character)
    end
  end
end
