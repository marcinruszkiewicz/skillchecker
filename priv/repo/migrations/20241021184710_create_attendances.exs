defmodule Skillchecker.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances) do
      add :name, :string
      add :times_flown, :integer
      add :sheet_name, :string
      add :practice_date, :date

      timestamps()
    end
  end
end
