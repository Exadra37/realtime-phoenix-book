defmodule HelloSocketsWeb.WildcardChannelTest do
  use HelloSocketsWeb.ChannelCase

  import ExUnit.CaptureLog

  alias HelloSocketsWeb.UserSocket

  describe "join/3 success" do
    test "ok when numbers in the format a:b where b = 2a" do
      assert {:ok, _, %Phoenix.Socket{}} =
        socket(UserSocket, nil, %{})
        |> subscribe_and_join("wild:2:4", %{})

      assert {:ok, _, %Phoenix.Socket{}} =
        socket(UserSocket, nil, %{})
        |> subscribe_and_join("wild:100:200", %{})
    end
  end

  # We are using == in these tests, rather than pattern matching, because we
  # care that the reply of the join function is exactly {:error, %{}} . If we used pattern
  # matching, then a return value like {:error, %{reason: "invalid"}} would incorrectly
  # pass the test.
  describe "join/3 error" do
    test "error when b is not exactly twice a" do
      assert {:error, %{}} == socket(UserSocket, nil, %{}) |> subscribe_and_join("wild:1:3", %{})
    end

    test "error when 3 numbers are provided" do
      assert {:error, %{}} == socket(UserSocket, nil, %{}) |> subscribe_and_join("wild:1:2:3", %{})
    end
  end

  describe "join/3 error causing crash" do
    test "error with an invalid format topic" do

      # We cause the crash to occur by passing in a topic that doesn’t have numbers
      # separated by a colon. This highlights one of the challenges of writing tests in
      # Elixir: if we use the built-in assert_raise/2 function, our test would fail because
      # the ArgumentError happens in a process other than our test process. We get
      # around this challenge by using the Logger to verify our assertions.
      #func = fn -> socket(UserSocket, nil, %{}) |> subscribe_and_join("wild:invalid", %{}) end
      #assert capture_log(func) =~ "[error] an exception was raised"

      # As per instructions in the book the WildcardChannel has been modified to
      # return an {:error, %{}} instead of raising
      assert {:error, %{}} = socket(UserSocket, nil, %{}) |> subscribe_and_join("wild:invalid", %{})
    end
  end
end
