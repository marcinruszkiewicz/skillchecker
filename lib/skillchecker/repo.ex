defmodule Skillchecker.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :skillchecker,
    adapter: Ecto.Adapters.Postgres
end
