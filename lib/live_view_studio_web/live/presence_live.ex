defmodule LiveViewStudioWeb.PresenceLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence

  @topic "users:video"

  def mount(_params, _session, socket) do
    # since this live view is running in a live session
    # the socket will have access to the current_user variable
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Presence.subscribe(@topic)

      {:ok, _} =
        Presence.track_user(current_user, @topic, %{
          is_playing: false
        })
    end

    presences =
      Presence.list_users(@topic)

    socket =
      socket
      |> assign(:is_playing, false)
      |> assign(:presences, Presence.simple_presence_map(presences))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <pre>
    <%!-- <%= inspect(@presences, pretty: true)%> --%>
    </pre>
    <div id="presence">
      <div class="users">
        <h2>Who's Here?</h2>
        
        <button phx-click={toggle_presences()}>
          <.icon name="hero-list-bullet-solid" />
        </button>
        
        <ul id="presences">
          <li :for={{_user_id, meta} <- @presences}>
            <span class="status">
              <%= if meta.is_playing,
                do: "😎",
                else: "😴" %>
            </span>
            
            <span class="username">
              <%= meta.username %>
            </span>
          </li>
        </ul>
      </div>
      
      <div class="video" phx-click="toggle-playing">
        <%= if @is_playing do %>
          <.icon name="hero-pause-circle-solid" />
        <% else %>
          <.icon name="hero-play-circle-solid" />
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)

    # we need also to update the pubsub to send the notifications
    # to the other users. to do that we need to get the current user
    %{current_user: current_user} = socket.assigns

    Presence.update_user(current_user, @topic, %{
      is_playing: socket.assigns.is_playing
    })

    # the presence_diff handel_info will take care of updating the
    # the socket for the other users
    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  def toggle_presences do
    JS.toggle(to: "#presences")
    |> JS.remove_class(
      "bg-slate-400",
      to: ".hero-list-bullet-solid.bg-slate-400"
    )
    |> JS.add_class(
      "bg-slate-400",
      to: ".hero-list-bullet-solid:not(.bg-slate-400)"
    )
  end
end
