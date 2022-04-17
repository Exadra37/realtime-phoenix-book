defmodule HelloSocketsWeb.AuthSocketTest do
  use HelloSocketsWeb.ChannelCase

  import ExUnit.CaptureLog

  alias HelloSocketsWeb.AuthSocket

  describe "connect/3 success" do
    test "can be connected to with a valid token" do
      assert {:ok, %Phoenix.Socket{}} = connect(AuthSocket, %{"token" => generate_token(1)})
      assert {:ok, %Phoenix.Socket{}} = connect(AuthSocket, %{"token" => generate_token(2)})
    end
  end

  describe "connect/3 error" do
    test "cannot be connected to with an invalid salt" do
      params = %{"token" => generate_token(1, salt: "invalid")}

      func = fn -> assert :error = connect(AuthSocket, params) end

      assert capture_log(func) =~ "[error] #{AuthSocket} connect error :invalid"
    end

    test "cannot be connected to without a token" do
      params = %{}

      func = fn -> assert :error = connect(AuthSocket, params) end

      assert capture_log(func) =~ "[error] #{AuthSocket} connect error missing params"
    end

    test "cannot be connected to without a nonsense token" do
      params = %{"token" => "non.sense"}

      func = fn -> assert :error = connect(AuthSocket, params) end

      assert capture_log(func) =~ "[error] #{AuthSocket} connect error :invalid"
    end
  end

  describe "id/1" do
    test "an identifier is based on the connected ID" do
      assert {:ok, socket} = connect(AuthSocket, %{"token" => generate_token(1)})
      assert AuthSocket.id(socket) == "auth_socket:1"

      assert {:ok, socket} = connect(AuthSocket, %{"token" => generate_token(2)})
      assert AuthSocket.id(socket) == "auth_socket:2"
    end
  end

  defp generate_token(id, opts \\ []) do
    salt = Keyword.get(opts, :salt, "salt identifier")
    Phoenix.Token.sign(HelloSocketsWeb.Endpoint, salt, id)
  end
end
