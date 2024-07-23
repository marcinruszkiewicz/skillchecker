defmodule Skillchecker.Repo.Migrations.AddSkillsToCharacters do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :primary_id, references(:skillsets, on_delete: :nothing)
      add :secondary_id, references(:skillsets, on_delete: :nothing)
      add :tertiary_id, references(:skillsets, on_delete: :nothing)
    end

    create index(:characters, [:primary_id])
    create index(:characters, [:secondary_id])
    create index(:characters, [:tertiary_id])
  end
end
