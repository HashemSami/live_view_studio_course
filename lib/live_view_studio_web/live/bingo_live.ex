defmodule LiveViewStudioWeb.BingoLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence

  @topic "users:bingo"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Presence.subscribe(@topic)

      {:ok, _} =
        Presence.track_user(current_user, @topic, %{
          time: Timex.now() |> Timex.format!("%H:%M", :strftime)
        })

      schedule_refresh(:timer.seconds(3))
    end

    presences =
      Presence.list_users(@topic)

    socket =
      assign(socket,
        number: nil,
        numbers: all_numbers()
      )
      |> assign(:presences, Presence.simple_presence_map(presences))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Bingo Boss 📢</h1>

    <div id="bingo">
      <div :for={{_user_id, meta} <- @presences} class="users">
        <ul>
          <li>
            <span class="username">
              <%= meta.username %>
            </span>
            
            <span class="timestamp">
              <%= meta.time %>
            </span>
          </li>
        </ul>
      </div>
      
      <div class="number">
        <%= @number %>
      </div>
    </div>
    """
  end

  # Assigns the next random bingo number, removing it
  # from the assigned list of numbers. Resets the list
  # when the last number has been picked.
  def pick(socket) do
    case socket.assigns.numbers do
      [head | []] ->
        assign(socket, number: head, numbers: all_numbers())

      [head | tail] ->
        assign(socket, number: head, numbers: tail)
    end
  end

  # Returns a list of all valid bingo numbers in random order.
  #
  # Example: ["B 4", "N 40", "O 73", "I 29", ...]
  def all_numbers() do
    ~w(B I N G O)
    |> Enum.zip(Enum.chunk_every(1..75, 15))
    |> Enum.flat_map(fn {letter, numbers} ->
      Enum.map(numbers, &"#{letter} #{&1}")
    end)
    |> Enum.shuffle()
  end

  def handle_info(:refresh, socket) do
    schedule_refresh(:timer.seconds(3))
    {:noreply, pick(socket)}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)
  end
end
