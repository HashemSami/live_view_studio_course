defmodule LiveViewStudioWeb.VolunteerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})

    # this will create a Phoenix.HTML.Form struct that we can
    # use in our heex template, which will use the fields in the ecto
    # database a validation to the form
    form = to_form(changeset)

    {:ok, assign(socket, :form, form)}
  end

  # this is a special function for the live component
  # that will be invoked after the mount component and
  # before the render, this function will assign any data
  # passed from the parent to the socket
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:count, assigns.count + 1)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="count">
        Go for it! You'll be volunteer #<%= @count %>
      </div>
      
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <.input
          field={@form[:name]}
          placeholder="Name"
          autocomplete="off"
          phx-debounce="2000"
        />
        <.input
          field={@form[:phone]}
          type="tel"
          placeholder="Phone"
          phx-debounce="blur"
          phx-hook="ValidatePhone"
        />
        <.button phx-disable-with="Saving...">
          Check In
        </.button>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, _volunteer} ->
        # we need to notify the parent live_view that the volunteer
        # has been created to render it, and since the live component
        # and live view run in the same process, we can send the data
        # to self() to handel the process in the parent live view
        # NOTE: if the parent is subscribed to the volunteers when
        # they are created, no need to send the message form here
        # send(self(), {__MODULE__, :volunteer_created, volunteer})

        # IO.inspect(socket.assigns.streams.volunteers, label: "save")

        changeset = Volunteers.change_volunteer(%Volunteer{})

        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    # IO.inspect(socket.assigns.streams.volunteers, label: "validate")

    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end
end
