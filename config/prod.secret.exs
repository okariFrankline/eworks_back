# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :eworks, Eworks.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :eworks, EworksWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# configure guardian
config :eworks, EworksWeb.Authentication.Guardian,
  issuer: "eworks",
  secret_key: {:system, "GUARDIAN_SECRET_KEY"}

# configuration for arc
config :arc,
  storage: Arc.Storage.S3,
  # set the virtual to true
  virtual_host: true,
  # bucket name
  bucket: {:system, "AWS_S3_BUCKET_NAME"},
  # the asset host
  asset_host: {:system, "AWS_S3_ASSET_HOST"},
  # the version timroute
  virtual_timeout: 100_000

# configure the aws
config :ex_aws,
  # use the default phoenix jason_library
  json_codec: Jason,
  secret_access_key: [{:system, "SECRET_ACCESS_KEY"}, :instance_role],
  access_key_id: [{:system, "ACCESS_KEY_ID"}, :instance_role],
  region: {:system, "AWS_REGION"}


# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :eworks, EworksWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
