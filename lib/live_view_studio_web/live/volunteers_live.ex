defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      # this will free the state of the all the volunteers from the process
      # and adding them to the dom with a unique ID to track the
      # changes from there
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    # IO.inspect(socket.assigns.streams.volunteers, label: "mount")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>

    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} /> <pre>
      <%!-- <%= inspect(@form, pretty: true)%> --%>
    </pre>
      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          id={volunteer_id}
          volunteer={volunteer}
        />
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :volunteer, Volunteer, required: true

  def volunteer(assigns) do
    ~H"""
    <div
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
      id={@id}
    >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      
      <div class="status">
        <button phx-click="toggle-status" phx-value-id={@volunteer.id}>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
        
        <.link
          class="delete"
          phx-click="delete-volunteer"
          phx-value-id={@volunteer.id}
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash-solid" />
        </.link>
      </div>
    </div>
    """
  end

  def handle_event("delete-volunteer", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} =
      Volunteers.delete_volunteer(volunteer)

    socket = stream_delete(socket, :volunteers, volunteer)

    IO.inspect(socket.assigns.streams.volunteers, label: "delete")
    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} =
      Volunteers.toggle_status_volunteer(volunteer)

    socket = stream_insert(socket, :volunteers, volunteer)
    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = stream_insert(socket, :volunteers, volunteer, at: 0)
    socket = put_flash(socket, :info, "Volunteer checked in!")
    # clearing the info plash after 3 second
    send(self(), "clear_flash")

    # increase the count by one
    socket = update(socket, :count, &(&1 + 1))
    {:noreply, socket}
  end

  def handle_info("clear_flash", socket) do
    :timer.sleep(3000)
    {:noreply, clear_flash(socket, :info)}
  end
end
