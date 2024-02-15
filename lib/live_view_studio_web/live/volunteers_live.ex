defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    # this will create a Phoenix.HTML.Form struct that we can
    # use in our heex template, which will use the fields in the ecto
    # database a validation to the form
    form = to_form(changeset)

    socket =
      assign(socket,
        volunteers: volunteers,
        form: form
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>

    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" />
        <.input field={@form[:phone]} type="tel" placeholder="Phone" />
        <.button phx-disable-with="Saving...">
          Check In
        </.button>
      </.form>
      <pre>
      <%!-- <%= inspect(@form, pretty: true)%> --%>
    </pre>
      <div
        :for={volunteer <- @volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
      >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        socket = update(socket, :volunteers, &[volunteer | &1])
        socket = put_flash(socket, :info, "Volunteer checked in!")
        changeset = Volunteers.change_volunteer(%Volunteer{})

        # clearing the info plash after 3 second
        send(self(), "clear_flash")

        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_info("clear_flash", socket) do
    :timer.sleep(3000)
    {:noreply, clear_flash(socket, :info)}
  end
end
