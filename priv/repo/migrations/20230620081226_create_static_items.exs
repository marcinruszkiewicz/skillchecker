defmodule Skillchecker.Repo.Migrations.CreateStaticItems do
  use Ecto.Migration

  def change do
    create table(:static_items) do
      add :name, :string
      add :eveid, :integer
      add :groupid, :integer

      add :mastery1, {:array, :integer}
      add :mastery2, {:array, :integer}
      add :mastery3, {:array, :integer}
      add :mastery4, {:array, :integer}
      add :mastery5, {:array, :integer}

      # 182
      add :required_skill_1_id, :integer
      # 277
      add :required_skill_1_level, :integer
      # 183
      add :required_skill_2_id, :integer
      # 278
      add :required_skill_2_level, :integer
      # 184
      add :required_skill_3_id, :integer
      # 279
      add :required_skill_3_level, :integer
      # 1285
      add :required_skill_4_id, :integer
      # 1286
      add :required_skill_4_level, :integer
      # 1289
      add :required_skill_5_id, :integer
      # 1287
      add :required_skill_5_level, :integer
      # 1290
      add :required_skill_6_id, :integer
      # 1288
      add :required_skill_6_level, :integer
      # 180
      add :primary_attribute_id, :integer
      # 181
      add :secondary_attribute_id, :integer
      # 275
      add :skill_multiplier, :integer
      # 280
      add :skill_level, :integer
      # attributeID: 1047
      add :omega_only, :integer
    end
  end
end
