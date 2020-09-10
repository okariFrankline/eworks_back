defmodule Eworks.Repo do
  use Ecto.Repo,
    otp_app: :eworks,
    adapter: Ecto.Adapters.Postgres
end
