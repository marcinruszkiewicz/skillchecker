defmodule Skillchecker.Repo do
  use Ecto.Repo,
    otp_app: :skillchecker,
    adapter: Ecto.Adapters.Postgres
end
