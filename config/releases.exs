# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :eworks, Eworks.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  start_apps_before_migration: [:logger]

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :eworks, EworksWeb.Endpoint,
  # set the server to true
  server: true,
  # use the port provided by the render
  url: [host: System.get_env("RENDER_EXTERNAL_HOSTNAME") || "localhost", port: 80],
  # cache_static_manifest: "priv/static/cache_manifest.json"
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# configure guardian
config :eworks, EworksWeb.Authentication.Guardian,
  issuer: "eworks",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# configure the aws
config :ex_aws,
  # use the default phoenix jason_library
  json_codec: Jason,
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  region: System.get_env("AWS_REGION")

# configuration for aws s3 storage
# config :ex_aws,
#   # use the default phoenix jason_library
#   json_codec: Jason,
#   access_key_id: System.get_env("SECRET_ACCESS_KEY"),
#   secret_access_key: System.get_env("ACCESS_KEY_ID"),
#   region: System.get_env("AWS_REGION")

config :waffle,
  storage: Waffle.Storage.S3,
  # set the virtual to true
  virtual_host: true,
  # bucket name
  bucket: System.get_env("AWS_S3_BUCKET_NAME"),
  # the asset host
  asset_host: System.get_env("AWS_S3_ASSET_HOST"),
  # the version timroute
  version_timeout: 100_000

# configuration for bamboo
config :eworks, Eworks.Utils.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")


# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
# config :eworks, EworksWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
