defmodule Skillchecker.CharactersTest do
  use Skillchecker.DataCase

  import Skillchecker.Factory

  alias Skillchecker.Characters
  alias Skillchecker.Characters.Character

  defp setup_characters(_) do
    character = insert(:character)
    pending = insert(:character, accepted: false, eveid: 55)

    %{character: character, pending: pending}
  end

  describe "list_characters/0" do
    setup :setup_characters

    test "returns all characters", %{character: character} do
      assert_struct_in_list(character, Characters.list_characters(), [:eveid, :name, :owner_hash])
    end
  end

  describe "list_pending_characters/0" do
    setup :setup_characters

    test "returns only pending", %{character: character, pending: pending} do
      assert_struct_in_list(pending, Characters.list_pending_characters(), [:eveid, :name, :owner_hash])

      refute Enum.any?(
               Characters.list_pending_characters(),
               fn x -> x.owner_hash == character.owner_hash end
             )
    end
  end

  describe "get_character!/1" do
    setup :setup_characters

    test "returns the character with given id", %{character: character} do
      assert_structs_equal(character, Characters.get_character!(character.id), [:eveid, :name, :owner_hash])
    end
  end

  describe "add_character!/1" do
    test "with valid data adds character" do
      valid_attrs = %{name: "some validd name", eveid: 43, accepted: false, owner_hash: "1233dfdf"}

      assert %Character{} = character = Characters.add_character(valid_attrs)
      assert character.name == "some validd name"
      assert character.eveid == 43
      assert character.accepted == false
    end

    test "with invalid data returns error changeset" do
      other_invalid_attrs = %{name: nil, eveid: nil, accepted: nil, owner_hash: "1234xx"}

      assert {:error, %Ecto.Changeset{}} =
               Characters.add_character(%{name: nil, eveid: nil, accepted: nil, owner_hash: nil})

      assert {:error, %Ecto.Changeset{}} = Characters.add_character(other_invalid_attrs)
    end

    test "with existing character with same owner hash returns that character" do
      existing = insert(:character, name: "some updated name", eveid: 43, accepted: false, owner_hash: "42zxc")
      valid_attrs = %{name: "some updated name", eveid: 43, accepted: false, owner_hash: "42zxc"}

      assert %Character{} = character = Characters.add_character(valid_attrs)
      assert character.name == existing.name
      assert character.eveid == existing.eveid
      assert character.accepted == existing.accepted
      assert character.owner_hash == existing.owner_hash
    end
  end

  describe "update_character/2" do
    setup :setup_characters

    test " with valid data updates the character", %{character: character} do
      update_attrs = %{name: "some updated name", eveid: 43, accepted: false, owner_hash: "123"}

      assert {:ok, %Character{} = character} = Characters.update_character(character, update_attrs)
      assert character.name == "some updated name"
      assert character.eveid == 43
      assert character.accepted == false
    end

    test "with invalid data returns error changeset", %{character: character} do
      assert {:error, %Ecto.Changeset{}} =
               Characters.update_character(character, %{name: nil, eveid: nil, accepted: nil, owner_hash: nil})

      assert_structs_equal(character, Characters.get_character!(character.id), [:eveid, :name, :owner_hash])
    end
  end

  describe "change_character/1" do
    setup :setup_characters

    test "returns a character changeset", %{character: character} do
      assert %Ecto.Changeset{} = Characters.change_character(character)
    end
  end
end
