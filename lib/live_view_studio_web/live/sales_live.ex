defmodule LiveViewStudioWeb.SalesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Sales

  @spec mount(any(), any(), any()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    if connected?(socket) do
      schedule_refresh(:timer.seconds(1))
    end

    socket =
      assign(socket,
        new_orders: Sales.new_orders(),
        sales_amount: Sales.sales_amount(),
        satisfaction: Sales.satisfaction(),
        interval: :timer.seconds(1)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Snappy Sales 📊</h1>

    <div id="sales">
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          
          <span class="label">
            New Orders
          </span>
        </div>
        
        <div class="stat">
          <span class="value">
            $<%= @sales_amount %>
          </span>
          
          <span class="label">
            Sales Amount
          </span>
        </div>
        
        <div class="stat">
          <span class="value">
            <%= @satisfaction %>%
          </span>
          
          <span class="label">
            Satisfaction
          </span>
        </div>
      </div>
      
      <button phx-click="refresh_button">
        <img src="/images/refresh.svg" /> Refresh
      </button>
    </div>
    """
  end

  defp schedule_refresh(refresh_interval) do
    Process.send_after(self(), :refresh, refresh_interval)
  end

  def handle_info(:refresh, socket) do
    schedule_refresh(socket.assigns.interval)
    {:noreply, assign_socket(socket)}
  end

  def handle_info(message, state) do
    # this will overwrite the error message generated
    # by the gen server when unregistered messaged
    # is called to the server
    IO.puts("wrong message key!!: #{inspect(message)}")
    {:noreply, state}
  end

  def handle_event("refresh_button", _unsigned_params, socket) do
    {:noreply, assign_socket(socket)}
  end

  defp assign_socket(socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction()
    )
  end
end
