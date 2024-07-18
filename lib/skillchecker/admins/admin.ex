defmodule Skillchecker.Admins.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field :email, :string
    field :accepted, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [:email, :accepted])
    |> validate_required([:email, :accepted])
  end
end
