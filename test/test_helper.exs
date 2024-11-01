ExUnit.start(exclude: [:skip])
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(Skillchecker.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)
