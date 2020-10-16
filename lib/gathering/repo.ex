defmodule Gathering.Repo do
  use Ecto.Repo,
    otp_app: :gathering,
    adapter: Ecto.Adapters.Postgres
end
