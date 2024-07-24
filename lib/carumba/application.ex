defmodule Carumba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CarumbaWeb.Telemetry,
      Carumba.Repo,
      {DNSCluster, query: Application.get_env(:carumba, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Carumba.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Carumba.Finch},
      # Start a worker by calling: Carumba.Worker.start_link(arg)
      # {Carumba.Worker, arg},
      # Start to serve requests, typically the last entry
      CarumbaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Carumba.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CarumbaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
