defmodule Skillchecker.StaticFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skillchecker.Static` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        name: "some name",
        skill_multiplier: 5,
        eveid: 5
      })
      |> Skillchecker.Static.create_item()

    item
  end

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        groupid: 42,
        name: "some name"
      })
      |> Skillchecker.Static.create_group()

    group
  end
end
