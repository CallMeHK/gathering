defmodule Gathering.MTGRepo do
  use Ecto.Repo,
    otp_app: :gathering,
    adapter: Ecto.Adapters.MyXQL
end
