defmodule HelloSocketsWeb.StatsChannel do
  use HelloSocketsWeb, :channel

  def join("valid", _payload, socket) do
    channel_join_increment("success")
    {:ok, socket}
  end

  def join("invalid", _payload, socket) do
    channel_join_increment("fail")
    {:error, %{reason: "always fail"} }
  end

  # You benefit from recording metadata such as status or Channel name in your
  # metric tags because you can drill deeper into the data. For example, you may
  # see an increase in Channel join events in your application. Is this due to
  # legitimate user traffic, or is there a bug that's preventing proper joins?
  # Capturing the join status in your tags means you have the correct data for
  # answering this question.
  defp channel_join_increment(status) do
    HelloSockets.Statix.increment(
      "channel_join",
      1,
      tags: ["status:#{status}", "channel:StatsChannel"]
    )
  end

  def handle_in("ping", _payload, socket) do
    func = fn ->
      Process.sleep(:rand.uniform(1000))
      {:reply, {:ok, %{ping: "pong"}}, socket}
    end

    # Measuring the time it took to process the ping request.
    HelloSockets.Statix.measure("stats_channel.ping", func)
  end
end
