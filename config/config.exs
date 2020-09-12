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
  url: [host: "localhost"],
  secret_key_base: "6CJOybNuGKnHBNeuc+Yuzmrr4TSnlqKld20e56Xd2r2le7k7Nz0QneMdSyepDT9w",
  render_errors: [view: EworksWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Eworks.PubSub,
  live_view: [signing_salt: "li2YCHmP"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# configuration for bamboo
config :eworks, Eworks.Utils.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {:system, "SENDGRID_API_KEY"}

# configure guardian
config :eworks, EworksWeb.Authentication.Guardian,
  issuer: "eworks",
  secret_key: {:system, "GUARDIAN_SECRET_KEY"}

# configure guardian
# config :guardian, Guardian.DB,
#   repo: Eworks.Repo,
#   schema_name: "guardian_tokens",
#   token_type: ["refress_tokens"],
#   sweep_intervals: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
