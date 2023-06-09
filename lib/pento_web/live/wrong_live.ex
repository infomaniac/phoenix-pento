defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view


  @range 1..6

  def mount(_params, _session, socket) do
    {:ok, assign(socket, range: @range, target: new_target(), score: 0, message: "Make a guess:", time: time() )}
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    guess |> String.to_integer |> handle_guess(socket)
  end

  defp handle_guess( guess, socket )
  when guess == socket.assigns.target do
    message = "Your guess: #{guess}. Correct. You win! Play again!"
    score = socket.assigns.score + ((@range |> Enum.count) / 2)
    {:noreply, assign(socket, score: score, message: message, time: time(), target: new_target() )}
    {:noreply, assign(socket, score: score, message: message, time: time(), target: new_target() )}
  end

  defp handle_guess(guess, socket) do
    message = "Your guess: #{guess}. Wrong. Guess again."
    score = socket.assigns.score - 1
    {:noreply, assign(socket, score: score, message: message, time: time() )}
  end

  defp new_target() do
    Enum.random(@range)
  end


  defp time() do
    DateTime.utc_now() |> to_string
  end

end
