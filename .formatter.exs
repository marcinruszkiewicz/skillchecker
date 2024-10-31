[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["config", "priv/*/migrations"],
  plugins: [Styler, Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
