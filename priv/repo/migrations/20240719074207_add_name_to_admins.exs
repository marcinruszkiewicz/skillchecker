defmodule Skillchecker.Repo.Migrations.AddNameToAdmins do
  use Ecto.Migration

  def change do
    alter table(:admins) do
      add :name, :string
    end
  end
end
