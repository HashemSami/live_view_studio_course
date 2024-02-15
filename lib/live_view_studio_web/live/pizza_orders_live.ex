defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [pizza_orders: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    pizza_orders = PizzaOrders.list_pizza_orders(options)
    pizza_order_count = PizzaOrders.count_pizza_orders()

    {:noreply,
     assign(socket,
       pizza_orders: pizza_orders,
       options: options,
       pizza_order_count: pizza_order_count
     )}
  end

  def handle_event("page_select", %{"per-page" => per_page}, socket) do
    {:noreply,
     push_patch(socket, to: ~p"/pizza-orders?#{%{socket.assigns.options | per_page: per_page}}")}
  end

  attr :options, :map, required: true
  attr :sort_by, :atom, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    ~H"""
    <.link patch={
      ~p"/pizza-orders?#{%{@options | sort_by: @sort_by, sort_order: next_sort_order(@options.sort_order)}}"
    }>
      <%= render_slot(@inner_block) %> <%= sort_indicator(
        @sort_by,
        @options
      ) %>
    </.link>
    """
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  defp sort_indicator(_, _), do: ""

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(size style topping_1 topping_2 price) do
    String.to_existing_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    String.to_existing_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc

  # when the param is not specified in the params
  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default
    end
  end

  defp next_page?(options, order_count) do
    options.page * options.per_page < order_count
  end

  defp pages(options, order_count) do
    page_count = ceil(order_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end
end
