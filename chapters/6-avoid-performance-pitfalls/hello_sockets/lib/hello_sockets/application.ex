defmodule HelloSockets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias HelloSockets.Pipeline.Producer
  alias HelloSockets.Pipeline.ConsumerSupervisor

  @impl true
  def start(_type, _args) do

    :ok = HelloSockets.Statix.connect()

    children = [
      # Start the Telemetry supervisor
      HelloSocketsWeb.Telemetry,

      # Start the PubSub system
      {Phoenix.PubSub, name: HelloSockets.PubSub},

      # We add each stage to our application before our Endpoint boots. This is
      # very important because we want our data pipeline to be available before
      # our web endpoints are available. If we didn't do this, we would
      # sometimes see “no process” errors.
      {Producer, name: Producer},
      # The min/max demand option helps us configure our pipeline to only process
      # a few items at a time. This should be configured to a low value for
      # in-memory workloads. It is better to have higher values if using an
      # external data store as this reduces the number of times we go to the
      # external data store.
      {ConsumerSupervisor, subscribe_to: [{Producer, max_demand: 20, min_demand: 5}]},

      # Start the Endpoint (http/https)
      HelloSocketsWeb.Endpoint,

      # Start a worker by calling: HelloSockets.Worker.start_link(arg)
      # {HelloSockets.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloSockets.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelloSocketsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
