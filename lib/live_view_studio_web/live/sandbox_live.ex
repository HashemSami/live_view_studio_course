defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  import Number.Currency
  alias LiveViewStudio.Sandbox

  def mount(_params, _session, socket) do
    # mounting the initial values
    socket =
      assign(
        socket,
        length: "0",
        width: "0",
        depth: "0",
        weight: 0.0,
        price: nil
      )

    {:ok, socket}
  end

  def handle_event("calculate", form_params, socket) do
    %{"length" => l, "width" => w, "depth" => d} = form_params

    weight = Sandbox.calculate_weight(l, w, d)

    socket =
      assign(socket,
        weight: weight,
        length: l,
        width: w,
        depth: d,
        price: nil
      )

    {:noreply, socket}
  end

  def handle_event("price", _form_params, socket) do
    %{weight: weight} = socket.assigns

    socket =
      assign(socket, price: Sandbox.calculate_price(weight))

    {:noreply, socket}
  end
end
