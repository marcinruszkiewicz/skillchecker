defmodule Skillchecker.MixProject do
  use Mix.Project

  def project do
    [
      app: :skillchecker,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Skillchecker.Application, []},
      extra_applications: [:logger, :runtime_tools, :logger_file_backend]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.19.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:plug_clacks, git: "https://github.com/hauleth/plug_clacks.git"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_eve_sso, git: "https://github.com/marcinruszkiewicz/ueberauth_eve_sso.git"},
      # {:ueberauth_eve_sso, path: "/Volumes/Projects/Aevi/ueberauth_eve_sso"},
      {:esi, git: "https://github.com/marcinruszkiewicz/esi.git"},
      {:httpoison, "~> 1.6"},
      {:yaml_elixir, "~> 2.9"},
      {:ex_cldr_units, "~> 3.16"},
      {:number, "~> 1.0"},
      {:ex_utils, "~> 0.1.7"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:assertions, "~> 0.20.1", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:logger_file_backend, "~> 0.0.14"},
      {:goth, "~> 1.4"},
      {:google_api_sheets, "~> 0.33"},
      {:timex, "~> 3.7"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
