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

  # To simulate a bottleneck in the Channel, where there is no parallelism
  # present, even though we're using one of the most parallel languages available!
  # The root cause of this problem is that our Channel is a single process that
  # can handle only one message at a time. When a message is slow to process,
  # other messages in the queue have to wait for it to complete. We artificially
  # added slowness into our handler, but something like a database query or API
  # call could cause this problem naturally.
  def handle_in("slow_ping", _payload, socket) do
    Process.sleep(:rand.uniform(3000))
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  # Phoenix provides a solution for the above slow_ping problem. We can respond
  # in a separate process that executes in parallel with our Channel, meaning we
  # can process all messages concurrently. We’ll use Phoenix’s socket_ref/1
  # function to turn our Socket into a minimally represented format that can be
  # passed around. Let’s make this change in our StatsChannel .
  def handle_in("parallel_slow_ping", _payload, socket) do
    # The ref variable used by this function is a stripped-down version of the
    # socket . We pass a reference to the Socket around, rather than the full
    # thing, to avoid copying potentially large amounts of memory around the
    # application.
    ref = socket_ref(socket)

    # Task is used to get a Process up and running very quickly. In practice,
    # however, you'll probably be calling into a GenServer. You should always
    # pass the socket_ref to any function you call.
    Task.start_link(fn ->
      Process.sleep(:rand.uniform(3000))

      # We use Phoenix.Channel.reply/2 to send a response to the Socket. This
      # serializes the message into a reply and sends it to the Socket transport
      # process. Once this occurs, our client receives the response as if it came
      # directly from the Channel. The outside client has no idea that any of
      # this occurred.
      Phoenix.Channel.reply(ref, {:ok, %{ping: "pong"}})
    end)

    {:noreply, socket}
  end
end
