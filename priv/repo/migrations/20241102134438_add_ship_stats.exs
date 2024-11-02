defmodule Skillchecker.Repo.Migrations.AddShipStats do
  use Ecto.Migration

  def change do
    create table(:flown_ships) do
      add :name, :string
      add :ship_name, :string
      add :sheet_name, :string
      add :practice_date, :date
    end
  end
end
