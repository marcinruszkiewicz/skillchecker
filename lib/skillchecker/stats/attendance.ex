defmodule Skillchecker.Stats.Attendance do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  schema "attendances" do
    field :name, :string
    field :times_flown, :integer
    field :sheet_name, :string
    field :practice_date, :date

    timestamps()
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:name, :times_flown, :sheet_name, :practice_date])
    |> validate_required([:name, :times_flown, :sheet_name, :practice_date])
  end
end
