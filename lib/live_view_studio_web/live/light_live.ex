defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # mount
  # the first function will be calledwhen the request comes
  # in through the router
  def mount(_params, _session, socket) do
    # the socket is a struct that is holding all the
    # live data sent to the router
    IO.inspect(self(), label: "MOUNT")
    socket = assign(socket, brightness: 10, temp: "3000")
    {:ok, socket}
  end

  # render
  # the render will receive what ever data struct we assigned
  # on the mount function
  def render(assigns) do
    # this function should return a template
    # using the ~H signal
    IO.inspect(self(), label: "RENDER")

    ~H"""
    <h1>Front Porch Light</h1>

    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background-color:#{temp_color(@temp)};"}>
          <%= assigns.brightness %>%
        </span>
      </div>
      
      <button phx-click="off">
        <img src="/images/light-off.svg" />
      </button>
      
      <button phx-click="down">
        <img src="/images/down.svg" />
      </button>
      
      <button phx-click="up">
        <img src="/images/up.svg" />
      </button>
      
      <button phx-click="on">
        <img src="/images/light-on.svg" />
      </button>
      
      <button phx-click="fire">
        <img src="/images/fire.svg" />
      </button>
      
      <form phx-change="slide">
        <input
          type="range"
          min="0"
          max="100"
          name="brightness"
          value={@brightness}
          phx-debounce="250"
        />
      </form>
      
      <form phx-change="color">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input
                checked={@temp == temp}
                type="radio"
                id={temp}
                name="temp"
                value={temp}
              /> <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  # handle_events using pattern matching
  def handle_event("on", _, socket) do
    IO.inspect(self(), label: "ON")

    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("slide", %{"brightness" => b}, socket) do
    socket = assign(socket, :brightness, String.to_integer(b))
    {:noreply, socket}
  end

  def handle_event("fire", _, socket) do
    socket = update(socket, :brightness, fn _val -> :rand.uniform(100) end)
    {:noreply, socket}
  end

  def handle_event("color", %{"temp" => t}, socket) do
    socket = assign(socket, :temp, t)
    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
