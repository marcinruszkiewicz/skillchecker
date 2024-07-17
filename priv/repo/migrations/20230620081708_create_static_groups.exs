defmodule Skillchecker.Repo.Migrations.CreateStaticGroups do
  use Ecto.Migration

  def change do
    create table(:static_groups) do
      add :groupid, :integer
      add :name, :string
    end
  end
end
