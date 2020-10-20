defmodule Gathering.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Gathering.Repo,
      Gathering.MTGRepo,
      # Start the Telemetry supervisor
      GatheringWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Gathering.PubSub},
      # Start the Endpoint (http/https)
      GatheringWeb.Endpoint
      # Start a worker by calling: Gathering.Worker.start_link(arg)
      # {Gathering.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gathering.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GatheringWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
