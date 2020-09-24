defmodule Eworks.MixProject do
  use Mix.Project

  def project do
    [
      app: :eworks,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Eworks.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix, "~> 1.5.4"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      # password hashing library
      {:argon2_elixir, "~> 2.3"},
      # library for validating the phone number
      {:ex_phone_number, "~> 0.2.0"},
      # bamboo library for sending an email
      {:bamboo, "~> 1.5"},
      # guardian for authentication
      {:guardian, "~> 2.1"},
      # guardian db for the tracking of the tokens
      {:guardian_db, "~> 2.0"},
      # arc for handing uploads and downloads of files
      {:arc, "~> 0.11.0"},
      # arc ecto to allow for the storing of information to the db
      {:arc_ecto, "~> 0.11.3"},
      # ex_aws for handling the interactions with aws storage
      {:ex_aws, "~> 2.1"},
      # ex_aws_s3 for handling uploads and downloads from aws s3 storage\
      {:ex_aws_s3, "~> 2.0"},
      # hackney
      {:hackney, "~> 1.16"},
      # sweet xml
      {:sweet_xml, "~> 0.6.6"}
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
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
