# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :eworks,
  ecto_repos: [Eworks.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :eworks, EworksWeb.Endpoint,
  # url: [host: "localhost"],
  # secret_key_base: "6CJOybNuGKnHBNeuc+Yuzmrr4TSnlqKld20e56Xd2r2le7k7Nz0QneMdSyepDT9w",
  render_errors: [view: EworksWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Eworks.PubSub,
  live_view: [signing_salt: "li2YCHmP"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# configuration of the cor plugs
config :cors_plug,
  origin: ["http://localhost:3000"],
  max_age: 86400,
  methods: ["GET", "POST"]

# configuration for bamboo
# config :eworks, Eworks.Utils.Mailer,
#   adapter: Bamboo.SendGridAdapter,
#   api_key: {:system, "SENDGRID_API_KEY"}

# config :eworks, Eworks.Utils.Mailer,
#   adapter: Bamboo.LocalAdapter

# # configure guardian
# config :eworks, EworksWeb.Authentication.Guardian,
#   issuer: "eworks",
#   secret_key: "v093/e5DdJwpN4uTAG1nYejCInpiw8/Z4N9BhT3/p3DyHkYmIToLlfl4YujdB5Ax"

# config :waffle,
#   storage: Waffle.Storage.S3,
#   # set the virtual to true
#   virtual_host: true,
#   # bucket name
#   bucket: "cf-simple-s3-origin-new-stack-072111920045",
#   # the asset host
#   asset_host: "http://d38ybxjihk2f55.cloudfront.net/",
#   # the version timroute
#   version_timeout: 100_000

# # config :waffle,
# #   storage: Waffle.Storage.S3,
# #   # set the virtual to true
# #   virtual_host: true,
# #   # bucket name
# #   bucket: "cf-simple-s3-origin-eworks-072111920045",
# #   # the asset host
# #   asset_host: "https://d12hykkw3lmuf.cloudfront.net/",
# #   # the version timroute
# #   version_timeout: 100_000

# # configure the aws
# config :ex_aws,
#   # use the default phoenix jason_library
#   json_codec: Jason,
#   access_key_id: "AKIARBSRUSOWZ23TJ57U",
#   secret_access_key: "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",
#   region: "ap-south-1"

config :cors_plug,
  origin: ["http://localhost:3000", "https://b8a3835de759.ngrok.io"],
  max_age: 86400,
  methods: ["GET", "POST"]
# configure guardian
# config :guardian, Guardian.DB,
#   repo: Eworks.Repo,
#   schema_name: "guardian_tokens",
#   token_type: ["refress_tokens"],
#   sweep_intervals: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
