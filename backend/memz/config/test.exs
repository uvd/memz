use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :memz, MemzWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :memz, Memz.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB")<>"_test",
  hostname: System.get_env("POSTGRES_HOST"),
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox
