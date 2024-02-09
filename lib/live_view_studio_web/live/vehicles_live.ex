defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Vehicles

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        vehicles: [],
        car: "",
        matches: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="cars" phx-change="suggest">
        <input
          type="text"
          name="query"
          value=""
          placeholder="Make or model"
          autofocus
          list="matches"
          autocomplete="off"
          phx-debounce="1000"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="matches">
        <option :for={name <- @matches} value={name}>
          <%= name %>
        </option>
      </datalist>

      <div :if={@loading} class="loader">Loading...</div>

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("cars", %{"query" => q}, socket) do
    send(self(), {:search_cars, q})

    {:noreply, assign(socket, loading: true, car: q)}
  end

  def handle_event("suggest", %{"query" => q}, socket) do
    send(self(), {:suggest_airport, q})
    {:noreply, socket}
  end

  def handle_info({:search_cars, q}, socket) do
    {:noreply, assign(socket, loading: false, vehicles: Vehicles.search(q))}
  end

  def handle_info({:suggest_airport, a}, socket) do
    IO.inspect(Vehicles.suggest(a))
    {:noreply, assign(socket, matches: Vehicles.suggest(a))}
  end
end
