defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudioWeb.ServerFormComponent

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

    socket =
      case socket.assigns.live_action == :new do
        true ->
          assign(socket, selected_server: nil, page_title: "new")

        false ->
          server = hd(socket.assigns.servers)
          assign(socket, selected_server: server, page_title: server.name)
      end

    {:noreply, socket}
  end

  attr :selected_server, Servers.Server, required: true

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @selected_server.name %></h2>
        
        <button
          class={@selected_server.status}
          phx-click="toggle-status"
          phx-value-id={@selected_server.id}
        >
          <%= @selected_server.status %>
        </button>
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

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)

    {:ok, server} =
      Servers.toggle_status_server(server)

    servers =
      socket.assigns.servers
      |> Enum.map(fn s ->
        if s.id == server.id,
          do: Map.put(s, :status, server.status),
          else: s
      end)

    {:noreply, assign(socket, servers: servers, selected_server: server)}
  end

  def handle_event("drink", _, socket) do
    IO.inspect(self(), label: "HANDLE DRINK EVENT")

    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_info({:server_created, server}, socket) do
    socket =
      update(socket, :servers, &[server | &1])
      |> put_flash(:info, "Server Saved!")

    send(self(), "clear_flash")

    {:noreply, push_patch(socket, to: ~p"/servers/#{server.id}")}
  end

  def handle_info("clear_flash", socket) do
    :timer.sleep(3000)
    {:noreply, clear_flash(socket, :info)}
  end
end
