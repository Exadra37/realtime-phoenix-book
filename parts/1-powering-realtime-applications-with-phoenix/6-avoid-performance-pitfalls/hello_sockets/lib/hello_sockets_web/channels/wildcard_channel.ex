defmodule HelloSocketsWeb.WildcardChannel do

  use HelloSocketsWeb, :channel

  @impl true
  def join("wild:" <> numbers, _payload, socket) do
    if numbers_correct?(numbers) do
      {:ok, socket}
    else
      {:error, %{}}
    end
  end

  @impl true
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{ping: "pong"}}, socket}
  end

  defp numbers_correct?(numbers) do
    numbers
    |> String.split(":")
    |> Enum.flat_map(&_to_integer/1)
    |> case do
      [a, b] when b == (a * 2) -> true
      _ -> false
    end
  end

  defp _to_integer(number) do
    case Integer.parse(number) do
      :error ->
        []

      {integer, _rest_of_string} ->
        [integer]
    end
  end

end
