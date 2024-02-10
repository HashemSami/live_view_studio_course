defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  attr :expiration, :integer, default: 24
  slot :legal, required: true
  slot :inner_block, required: true

  def promo(assigns) do
    # the assign function can except either a socket of an assigned argument
    # and now  we can access the new variable @minutes to the template
    assigns = assign(assigns, :minutes, assigns.expiration * 60)

    # we can use assign_new to generate the value is the attr not required

    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      
      <div class="expiration">
        Deal expires in <%= @expiration %> hours!
      </div>
      
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end

  attr :loading, :boolean, default: false

  def loading_indicator(assigns) do
    ~H"""
    <div :if={@loading} class="flex justify-center my-10 relative">
      <div class="w-12 h-12 rounded-full absolute border-8 border-gray-300">
      </div>
      
      <div class="w-12 h-12 rounded-full absolute border-8 border-indigo-400 border-t-transparent animate-spin">
      </div>
    </div>
    """
  end
end
