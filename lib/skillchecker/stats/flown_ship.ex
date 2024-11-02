defmodule Skillchecker.Stats.FlownShip do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "flown_ships" do
    field :name, :string
    field :ship_name, :string
    field :sheet_name, :string
    field :practice_date, :date
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:name, :ship_name, :sheet_name, :practice_date])
    |> validate_required([:name, :ship_name, :sheet_name, :practice_date])
  end
end
