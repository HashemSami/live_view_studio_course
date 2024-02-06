defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # mount
  # the first function will be calledwhen the request comes
  # in through the router
  def mount(_params, _session, socket) do
    # the socket is a struct that is holding all the
    # live data sent to the router
    IO.inspect(self(), label: "MOUNT")
    socket = assign(socket, brightness: 10)
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
    <h1> Front Porch Light</h1>
    <div id="light">
        <div class="meter">
          <span style ={"width: #{@brightness}%"} >
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
          <img src="/images/light-on.svg"/>
        </button>
        <button phx-click="fire">
          <img src="/images/fire.svg"/>
        </button>
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

  def handle_event("fire", _, socket) do
    socket = update(socket, :brightness, fn _val -> :rand.uniform(100) end)
    {:noreply, socket}
  end
end
