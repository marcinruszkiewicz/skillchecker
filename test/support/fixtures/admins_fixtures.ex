defmodule Skillchecker.AdminsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skillchecker.Admins` context.
  """

  @doc """
  Generate a admin.
  """
  def admin_fixture(attrs \\ %{}) do
    {:ok, admin} =
      attrs
      |> Enum.into(%{
        accepted: true,
        email: "some email"
      })
      |> Skillchecker.Admins.create_admin()

    admin
  end
end
