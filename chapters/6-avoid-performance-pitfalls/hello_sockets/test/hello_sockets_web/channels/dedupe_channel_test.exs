defmodule HelloSocketsWeb.DedupeChannelTest do
  use HelloSocketsWeb.ChannelCase

  alias HelloSocketsWeb.UserSocket

  test "a buffer is maintained as numbers are broadcasted" do
    connect()
    |> broadcast_number(1)
    |> validate_buffer_contents([1])
    |> broadcast_number(1)
    |> validate_buffer_contents([1, 1])
    |> broadcast_number(2)
    |> validate_buffer_contents([2, 1, 1])

    # We ensure that no message has been sent to the client by using refute_push/2
    # with very loose values (_, _) on the pattern matching.
    refute_push _, _
  end

  test "the buffer is drained 1 second after a number is first added" do
    connect()
    |> broadcast_number(1)
    |> broadcast_number(1)
    |> broadcast_number(2)

    # We are using Process.sleep/1 in order to wait long enough for our Channel to
    # have drained the buffer. This can cause the test suite to be slower, although
    # there are slightly more complex alternatives. If you placed a configurable
    # timeout for draining the buffer in the test suite, you would be able to sleep
    # for much less time. Alternatively, you could develop a way to ask the Channel
    # process how many times it has drained and then wait until it increases. The
    # sleep function is great for this test because it keeps the code simple.
    Process.sleep(1050)

    timeout = 0

    # assert_push/3 and refute_push/3 delegate to ExUnit’s assert_receive and refute_receive
    # functions with a pattern that matches the expected Phoenix.Socket.Message . This
    # means the Channel messages are located in our test process’s mailbox and
    # can be inspected manually when necessary. We are providing a timeout of 0
    # for these functions, as we have already waited enough time for the processing
    # to have finished.

    assert_push "number", %{value: 1}, timeout

    # We ensure that no message has been sent to the client by using refute_push/2
    # by pattern matching the expected values.
    refute_push "number", %{value: 1}, timeout

    assert_push "number", %{value: 2}, timeout
  end

  test "the buffer drains with unique values in hte correct order" do
    connect()
    |> broadcast_number(1)
    |> broadcast_number(2)
    |> broadcast_number(3)
    |> broadcast_number(2)

    Process.sleep(1050)

    assert {:messages, [
      %Phoenix.Socket.Message{
        event: "number",
        payload: %{value: 1}
      },
      %Phoenix.Socket.Message{
        event: "number",
        payload: %{value: 2}
      },
      %Phoenix.Socket.Message{
        event: "number",
        payload: %{value: 3}
      }
    ]} = Process.info(self(), :messages)
  end

  defp broadcast_number(socket, number) do
    # We use broadcast_from!/3 to trigger handle_out of our Channel. The broadcast
    # function invokes the PubSub callbacks present in the Phoenix.Channel.Server
    # module.
    assert broadcast_from!(socket, "number", %{number: number}) == :ok

    socket
  end

  defp validate_buffer_contents(socket, expected_contents) do
    assigns = %{
      awaiting_buffer?: true,
      buffer: expected_contents
    }

    # We use :sys.get_state/1 to retrieve the contents of our Channel.Server process that
    # is created by the test helper. This creates a tight coupling between the process
    # being spied on and the calling process, so you should limit its usage. It can
    # be valuable when used sparingly in tests because it gives all the information
    # about a process.
    assert :sys.get_state(socket.channel_pid).assigns == assigns

    socket
  end

  defp connect() do
    assert{:ok, _, socket} = socket(UserSocket, nil, %{}) |> subscribe_and_join("dupe", %{})

    socket
  end

end
