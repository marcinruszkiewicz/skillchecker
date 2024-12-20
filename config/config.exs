# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :skillchecker,
  ecto_repos: [Skillchecker.Repo]

# Configures the endpoint
config :skillchecker, SkillcheckerWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: SkillcheckerWeb.ErrorHTML, json: SkillcheckerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Skillchecker.PubSub,
  live_view: [signing_salt: "KLnpjJrN"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :debug

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    evesso:
      {Ueberauth.Strategy.EVESSO,
       [
         default_scope: "publicData esi-skills.read_skills.v1 esi-skills.read_skillqueue.v1"
       ]}
  ]

config :ueberauth, Ueberauth.Strategy.EVESSO.OAuth,
  client_id: System.get_env("ATS_ESI_CLIENT_ID"),
  client_secret: System.get_env("ATS_ESI_CLIENT_SECRET")

config :skillchecker, :ex_cldr_units, default_backend: Skillchecker.Cldr

config :oauth2, debug: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
