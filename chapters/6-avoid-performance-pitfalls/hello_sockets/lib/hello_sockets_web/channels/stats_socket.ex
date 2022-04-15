defmodule HelloSocketsWeb.StatsSocket do
  use Phoenix.Socket

  channel "*", HelloSocketsWeb.StatsChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    HelloSockets.Statix.increment(
      "socket_connect",
      1,
      tags: ["status:success", "socket:StatsSocket"]
    )

    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil

end
