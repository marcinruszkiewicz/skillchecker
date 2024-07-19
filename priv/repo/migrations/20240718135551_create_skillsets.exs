defmodule Skillchecker.Repo.Migrations.CreateSkillsets do
  use Ecto.Migration

  def change do
    create table(:skillsets) do
      add :name, :string
      add :skills, :jsonb

      timestamps()
    end
  end
end
