defmodule Eworks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Eworks.Repo,
      # Start the Telemetry supervisor
      EworksWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Eworks.PubSub},
      # Start the Endpoint (http/https)
      EworksWeb.Endpoint,
      # Start a worker by calling: Eworks.Worker.start_link(arg)
      # {Eworks.Worker, arg}
      Eworks.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eworks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EworksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
