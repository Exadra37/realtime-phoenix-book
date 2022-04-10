defmodule HelloSocketsWeb.PingChannel do

  use HelloSocketsWeb, :channel

  @impl true
  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

end
