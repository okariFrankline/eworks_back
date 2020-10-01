defmodule Eworks.Repo do
  use Ecto.Repo,
    otp_app: :eworks,
    adapter: Ecto.Adapters.Postgres

  # use the paginator
  use Paginator, limit: 10
end
