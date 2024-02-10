defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{type: "", prices: []},
        boats: Boats.list_boats()
      )

    # {:ok, socket}
    {:ok, socket, temporary_assigns: [boats: []]}
    # temporary_assigns will reset the boats list to an empty list
    # each time it renders the data to the user to free up the memory
    # in the process instead of cache the list
    # we use it when we fetch any static data from the database
    # to render it to the user
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>

    <.promo>
      Save 25% on rentals!
      <:legal>
        <Heroicons.exclamation_circle /> Limit 1 per party
      </:legal>
    </.promo>

    <div id="boats">
      <.filter_form filter={@filter} />
      <div class="boats">
        <.boat :for={boat <- @boats} boat={boat} />
      </div>
    </div>

    <.promo expiration={1}>
      Hurry, only three boats left!
      <:legal>
        Excluding weekends
      </:legal>
    </.promo>
    """
  end

  attr :filter, :map, required: true

  def filter_form(assigns) do
    ~H"""
    <form phx-change="filter">
      <div class="filters">
        <select name="type">
          <%= Phoenix.HTML.Form.options_for_select(
            type_options(),
            @filter.type
          ) %>
        </select>
        
        <div class="prices">
          <%= for price <- ["$", "$$", "$$$"] do %>
            <input
              type="checkbox"
              name="prices[]"
              value={price}
              id={price}
              checked={price in @filter.prices}
            /> <label for={price}><%= price %></label>
          <% end %>
           <input type="hidden" name="prices[]" value="" />
        </div>
      </div>
    </form>
    """
  end

  attr :boat, LiveViewStudio.Boats.Boat, required: true

  def boat(assigns) do
    ~H"""
    <div class="boat">
      <img src={@boat.image} />
      <div class="content">
        <div class="model">
          <%= @boat.model %>
        </div>
        
        <div class="details">
          <span class="price">
            <%= @boat.price %>
          </span>
          
          <span class="type">
            <%= @boat.type %>
          </span>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    filter = %{type: type, prices: prices}
    boats = Boats.list_boats(filter)

    IO.inspect(length(socket.assigns.boats), label: "Assigned boats")
    IO.inspect(length(boats), label: "Filtered boats")

    {:noreply, assign(socket, boats: boats, filter: filter)}
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
