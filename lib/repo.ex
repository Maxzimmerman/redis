defmodule Repo do
  use Ecto.Repo,
    otp_app: :codecrafters_redis,
    adapter: Ecto.Adapters.Postgres
end
