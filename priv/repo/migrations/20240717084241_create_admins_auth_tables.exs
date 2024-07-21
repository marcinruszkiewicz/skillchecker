defmodule Skillchecker.Repo.Migrations.CreateAdminsAuthTables do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :name, :string, null: false
      add :hashed_password, :string, null: false
      add :accepted, :boolean, null: false, default: false

      timestamps()
    end

    create unique_index(:admins, [:name])

    create table(:admins_tokens) do
      add :admin_id, references(:admins, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(updated_at: false)
    end

    create index(:admins_tokens, [:admin_id])
    create unique_index(:admins_tokens, [:context, :token])
  end
end
