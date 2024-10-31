defmodule Skillchecker.Static.Item do
  @moduledoc """
  Items from EVE SDE.

  We're only interested in skills here but those are all possible items.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "static_items" do
    field :eveid, :integer
    field :name, :string
    field :mastery1, {:array, :integer}
    field :mastery2, {:array, :integer}
    field :mastery3, {:array, :integer}
    field :mastery4, {:array, :integer}
    field :mastery5, {:array, :integer}
    field :groupid, :integer
    # 182
    field :required_skill_1_id, :integer
    # 277
    field :required_skill_1_level, :integer
    # 183
    field :required_skill_2_id, :integer
    # 278
    field :required_skill_2_level, :integer
    # 184
    field :required_skill_3_id, :integer
    # 279
    field :required_skill_3_level, :integer
    # 1285
    field :required_skill_4_id, :integer
    # 1286
    field :required_skill_4_level, :integer
    # 1289
    field :required_skill_5_id, :integer
    # 1287
    field :required_skill_5_level, :integer
    # 1290
    field :required_skill_6_id, :integer
    # 1288
    field :required_skill_6_level, :integer
    # 180
    field :primary_attribute_id, :integer
    # 181
    field :secondary_attribute_id, :integer
    # 275
    field :skill_multiplier, :integer
    # 280
    field :skill_level, :integer
    # attributeID: 1047
    field :omega_only, :integer
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :name,
      :eveid,
      :mastery1,
      :mastery2,
      :mastery3,
      :mastery4,
      :mastery5,
      :groupid,
      :required_skill_1_id,
      :required_skill_1_level,
      :required_skill_2_id,
      :required_skill_2_level,
      :required_skill_3_id,
      :required_skill_3_level,
      :required_skill_4_id,
      :required_skill_4_level,
      :required_skill_5_id,
      :required_skill_5_level,
      :required_skill_6_id,
      :required_skill_6_level,
      :primary_attribute_id,
      :secondary_attribute_id,
      :skill_multiplier,
      :skill_level,
      :omega_only
    ])
    |> validate_required([:name, :eveid])
  end
end
