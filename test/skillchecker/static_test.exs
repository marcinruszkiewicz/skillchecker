defmodule Skillchecker.StaticTest do
  use Skillchecker.DataCase
  alias Skillchecker.Static
  alias Skillchecker.Static.{Item, Group}

  import Skillchecker.StaticFixtures

  @invalid_attrs %{name: nil, eveid: nil}
  @invalid_group_attrs %{name: nil, groupid: nil}

  describe "get_item_name/1" do
    test "returns name of the item if it exists" do
      item_fixture(%{name: "Cool Skill", eveid: 456})

      assert Static.get_item_name(456) == "Cool Skill"
    end

    test "returns empty string if item doesn't exist" do
      assert Static.get_item_name(48484) == ""
    end
  end

  describe "get_group_name/1" do
    test "returns name of the item group if it exists" do
      group_fixture(%{name: "Our Skills", groupid: 4323})
      item_fixture(%{name: "Cool Skill", eveid: 456, groupid: 4323})

      assert Static.get_group_name(456) == "Our Skills"
    end

    test "returns empty string if item doesn't exist" do
      assert Static.get_group_name(48484) == ""
    end

    test "returns empty string if group doesn't exist" do
      item_fixture(%{name: "Cool Skill", eveid: 456, groupid: 4323})

      assert Static.get_group_name(456) == ""
    end
  end

  describe "find_item_eveid/1" do
    test "returns id if item found" do
      item_fixture(%{name: "Cool Skill", eveid: 456})

      assert Static.find_item_eveid("Cool Skill") == 456
    end
  end

  describe "get_skill_multiplier/1" do
    test "returns multiplier if skill present" do
      item_fixture(%{name: "Cool Skill", eveid: 456, skill_multiplier: 12})

      assert Static.get_skill_multiplier(456) == 12
    end

    test "returns nil if no skill present" do
      assert Static.get_skill_multiplier(1324) == nil
    end
  end

  describe "list_static_items/0" do
    test "returns all items" do
      s1 = item_fixture(%{name: "Cool Skill 1", eveid: 1})
      s2 = item_fixture(%{name: "Cool Skill 2", eveid: 2})
      s3 = item_fixture(%{name: "Cool Skill 3", eveid: 3})

      list = Static.list_static_items
      assert_struct_in_list s1, list, [:name, :eveid]
      assert_struct_in_list s2, list, [:name, :eveid]
      assert_struct_in_list s3, list, [:name, :eveid]
    end
  end

  describe "get_item!/1" do
    test "returns the item with given id" do
      item = item_fixture()
      assert_structs_equal item, Static.get_item!(item.id), [:eveid, :name]
    end
  end

  describe "update_item/2" do
    test "with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{name: "some updated name", eveid: 987}

      assert {:ok, %Item{} = item} = Static.update_item(item, update_attrs)
      assert item.name == "some updated name"
      assert item.eveid == 987
    end

    test "with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Static.update_item(item, @invalid_attrs)
      assert item == Static.get_item!(item.id)
    end
  end

  describe "delete_item/1" do
    test "deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Static.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Static.get_item!(item.id) end
    end
  end

  describe "change_item/1" do
    test "returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Static.change_item(item)
    end
  end

  describe "list_static_groups/0" do
    test "returns all groups" do
      s1 = group_fixture(%{name: "Cool Skill 1", groupid: 1})
      s2 = group_fixture(%{name: "Cool Skill 2", groupid: 2})
      s3 = group_fixture(%{name: "Cool Skill 3", groupid: 3})

      list = Static.list_static_groups
      assert_struct_in_list s1, list, [:name, :groupid]
      assert_struct_in_list s2, list, [:name, :groupid]
      assert_struct_in_list s3, list, [:name, :groupid]
    end
  end

  describe "get_group!/1" do
    test "returns the group with given id" do
      group = group_fixture()
      assert_structs_equal group, Static.get_group!(group.id), [:groupid, :name]
    end
  end

  describe "update_group/2" do
    test "with valid data updates the group" do
      group = group_fixture()
      update_attrs = %{name: "some updated name", groupid: 987}

      assert {:ok, %Group{} = group} = Static.update_group(group, update_attrs)
      assert group.name == "some updated name"
      assert group.groupid == 987
    end

    test "with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Static.update_group(group, @invalid_group_attrs)
      assert group == Static.get_group!(group.id)
    end
  end

  describe "delete_group/1" do
    test "deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Static.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Static.get_group!(group.id) end
    end
  end

  describe "change_group/1" do
    test "returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Static.change_group(group)
    end
  end
end
