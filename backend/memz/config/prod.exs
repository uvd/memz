use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# MemzWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
config :memz, MemzWeb.Endpoint,
  http: [port: "${PORT}"],
  url: [host: "${HOST}", port: "${PORT}"],
  server: true,
  root: ".",
  version: Application.spec(:myapp, :vsn),
  secret_key_base: "${SECRET_KEY_BASE}"


# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :memz, MemzWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :memz, MemzWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :memz, MemzWeb.Endpoint, server: true
#
# Configure your database
config :memz, Memz.Repo,
   adapter: Ecto.Adapters.Postgres,
   username: "${POSTGRES_USER}",
   password: "${POSTGRES_PASSWORD}",
   hostname: "${POSTGRES_HOST}",
   database: "${POSTGRES_DB}",
   port: "${POSTGRES_PORT}",
   pool_size: 20