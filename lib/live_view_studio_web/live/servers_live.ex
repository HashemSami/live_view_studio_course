defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "MOUNT")
    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        coffees: 0
      )

    {:ok, socket}
  end

  # handle_params always invoked after the mount function
  # then it will be invoked every time the url changes
  def handle_params(%{"id" => id}, _uri, socket) do
    IO.inspect(self(), label: "PARAMS ID = #{id}")

    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: server.name)}
  end

  # to handle the case where there is no params for the page
  def handle_params(_, _uri, socket) do
    IO.inspect(self(), label: "PARAMS CATCH ALL")

    server = hd(socket.assigns.servers)

    {:noreply, assign(socket, selected_server: server, page_title: server.name)}
  end

  def render(assigns) do
    IO.inspect(self(), label: "RENDER")

    ~H"""
    <h1>Servers</h1>

    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server.id}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span> <%= server.name %>
          </.link>
        </div>
        
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" /> <%= @coffees %>
          </button>
        </div>
      </div>
      
      <div class="main">
        <div class="wrapper">
          <.server selected_server={@selected_server} />
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust Light
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :selected_server, Servers.Server, required: true

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @selected_server.name %></h2>
        
        <span class={@selected_server.status}>
          <%= @selected_server.status %>
        </span>
      </div>
      
      <div class="body">
        <div class="row">
          <span>
            <%= @selected_server.deploy_count %> deploys
          </span>
          
          <span>
            <%= @selected_server.size %> MB
          </span>
          
          <span>
            <%= @selected_server.framework %>
          </span>
        </div>
        
        <h3>Last Commit Message:</h3>
        
        <blockquote>
          <%= @selected_server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end

  def handle_event("drink", _, socket) do
    IO.inspect(self(), label: "HANDLE DRINK EVENT")

    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end
end
