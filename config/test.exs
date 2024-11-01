import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :skillchecker, Skillchecker.Repo,
  username: "skyace",
  password: "",
  hostname: "localhost",
  database: "skillchecker_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :skillchecker, SkillcheckerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "7BVtHS4hdNH4B8N2wXUTE2ezErOVe+CwCJq2arCbD3Umf6BDPBqEPypx635Vzs6q",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_test, :endpoint, SkillcheckerWeb.Endpoint
