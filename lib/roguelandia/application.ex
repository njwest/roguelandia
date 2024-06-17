defmodule Roguelandia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RoguelandiaWeb.Telemetry,
      Roguelandia.Repo,
      {DNSCluster, query: Application.get_env(:roguelandia, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Roguelandia.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Roguelandia.Finch},
      # Start a worker by calling: Roguelandia.Worker.start_link(arg)
      # {Roguelandia.Worker, arg},
      RoguelandiaWeb.Presence,
      RoguelandiaWeb.Endpoint,
      # Start a dynamic supervisor for battle servers
      {DynamicSupervisor, strategy: :one_for_one, name: BattleSupervisor},
      # Start a registry for battle servers
      Registry.child_spec(keys: :unique, name: BattleRegistry)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Roguelandia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RoguelandiaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
