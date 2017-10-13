# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :memz,
  ecto_repos: [Memz.Repo]

# Configures the endpoint
config :memz, MemzWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WWjYKvggkcIs9LgbcgfX4Sb/6v8PtToce3RWqjCloGcqlNvknYA/rWEKYP3pVXVU",
  render_errors: [view: MemzWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Memz.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Guardian
config :memz, MemzWeb.Guardian,
  issuer: "MEMZ",
  secret_key: "CyNQmG/EVQdO2MFxIKYVhjNV1SAZ/3Inn1fn5CnxJL8vmLe/5VyCR0MLunFk5e3R",
  error_handler: MemzWeb.ErrorHandler

config :cors_plug,
       expose: ["Authorization"]

config :arc,
       storage: Arc.Storage.S3, # or Arc.Storage.Local
       bucket: {:system, "AWS_S3_BUCKET"}, # if using Amazon S3
       asset_host: "http://localhost:9000/event-images"

config :ex_aws,
       access_key_id: ["AKIAIZS7ZZEIGYWFI5RQ", :instance_role],
       secret_access_key: ["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", :instance_role],
       region: "eu-west-2",
       s3: [
          scheme: "http://",
          host: "minio",
          port: 9000,
          region: "eu-west-2"
       ]

if Mix.env == :dev do
  config :mix_test_watch,
     tasks: [
       "test",
       "credo",
       "dogma"
     ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"