defmodule LiveViewStudioWeb.ServerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers.Server
  alias LiveViewStudio.Servers

  def mount(socket) do
    changeset = Servers.change_server(%Server{})
    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="field">
          <.input
            field={@form[:name]}
            placeholder="Name"
            autocomplete="off"
            phx-debounce="2000"
          />
        </div>
        
        <div class="field">
          <.input
            field={@form[:framework]}
            placeholder="Framework"
            autocomplete="off"
            phx-debounce="2000"
          />
        </div>
        
        <div class="field">
          <.input
            field={@form[:size]}
            placeholder="Size"
            autocomplete="off"
            type="number"
            phx-debounce="blur"
          />
        </div>
        
        <.button phx-disable-with="Saving...">
          Submit
        </.button>
        
        <.link patch={~p"/servers"} class="cancel">
          Cancel
        </.link>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    IO.inspect(server_params, label: "server_params")

    case Servers.create_server(server_params) do
      {:ok, server} ->
        # send(self(), {:server_created, server})

        {:noreply, push_patch(socket, to: ~p"/servers/#{server.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end
end
