defmodule Skillchecker.Repo.Migrations.AddCharacterFields do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :refreshed_at, :utc_datetime
      add :uuid, :uuid
    end
  end
end
