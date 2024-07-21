defmodule Skillchecker.Static.Group do
  @moduledoc """
  Groups of items from EVE SDE
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "static_groups" do
    field :groupid, :integer
    field :name, :string
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:groupid, :name])
    |> validate_required([:groupid, :name])
  end
end
