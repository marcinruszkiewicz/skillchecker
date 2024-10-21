defmodule Skillchecker.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skillchecker.Stats` context.
  """

  @doc """
  Generate a attendance.
  """
  def attendance_fixture(attrs \\ %{}) do
    {:ok, attendance} =
      attrs
      |> Enum.into(%{
        name: "some name",
        practice_date: ~D[2024-10-20],
        sheet_name: "some sheet_name",
        times_flown: 42
      })
      |> Skillchecker.Stats.create_attendance()

    attendance
  end
end
