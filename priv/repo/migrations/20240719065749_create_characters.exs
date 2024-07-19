defmodule Skillchecker.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :accepted, :boolean, default: false, null: false

      add :name, :string
      add :thumbnail_url, :string
      add :picture_url, :string
      add :owner_hash, :string
      add :eveid, :integer
      add :token, :text
      add :refresh_token, :string
      add :expires_at, :utc_datetime
      add :data, :jsonb
      add :skill_queue, :jsonb
      add :skills, :jsonb

      timestamps()
    end
  end
end
