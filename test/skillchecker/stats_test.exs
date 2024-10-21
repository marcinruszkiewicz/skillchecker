defmodule Skillchecker.StatsTest do
  use Skillchecker.DataCase

  alias Skillchecker.Stats

  describe "attendances" do
    alias Skillchecker.Stats.Attendance

    import Skillchecker.StatsFixtures

    @invalid_attrs %{name: nil, times_flown: nil, sheet_name: nil, practice_date: nil}

    test "list_attendances/0 returns all attendances" do
      attendance = attendance_fixture()
      assert Stats.list_attendances() == [attendance]
    end

    test "get_attendance!/1 returns the attendance with given id" do
      attendance = attendance_fixture()
      assert Stats.get_attendance!(attendance.id) == attendance
    end

    test "create_attendance/1 with valid data creates a attendance" do
      valid_attrs = %{name: "some name", times_flown: 42, sheet_name: "some sheet_name", practice_date: ~D[2024-10-20]}

      assert {:ok, %Attendance{} = attendance} = Stats.create_attendance(valid_attrs)
      assert attendance.name == "some name"
      assert attendance.times_flown == 42
      assert attendance.sheet_name == "some sheet_name"
      assert attendance.practice_date == ~D[2024-10-20]
    end

    test "create_attendance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_attendance(@invalid_attrs)
    end

    test "update_attendance/2 with valid data updates the attendance" do
      attendance = attendance_fixture()
      update_attrs = %{name: "some updated name", times_flown: 43, sheet_name: "some updated sheet_name", practice_date: ~D[2024-10-21]}

      assert {:ok, %Attendance{} = attendance} = Stats.update_attendance(attendance, update_attrs)
      assert attendance.name == "some updated name"
      assert attendance.times_flown == 43
      assert attendance.sheet_name == "some updated sheet_name"
      assert attendance.practice_date == ~D[2024-10-21]
    end

    test "update_attendance/2 with invalid data returns error changeset" do
      attendance = attendance_fixture()
      assert {:error, %Ecto.Changeset{}} = Stats.update_attendance(attendance, @invalid_attrs)
      assert attendance == Stats.get_attendance!(attendance.id)
    end

    test "delete_attendance/1 deletes the attendance" do
      attendance = attendance_fixture()
      assert {:ok, %Attendance{}} = Stats.delete_attendance(attendance)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_attendance!(attendance.id) end
    end

    test "change_attendance/1 returns a attendance changeset" do
      attendance = attendance_fixture()
      assert %Ecto.Changeset{} = Stats.change_attendance(attendance)
    end
  end
end
