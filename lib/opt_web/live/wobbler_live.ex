defmodule OptWeb.WobblerLive do
  use OptWeb, :live_view

  @sec 1000

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :tick, @sec)
    end

    socket = assign(socket, step: 0, tick_time: @sec, counter: 50, halting: false, past_steps: [])
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="wobbler">
      <h1>Simple Wobbler</h1>
      <h2>Step <%= @step %></h2>
      <div class="phx-hero">
        <h3>Current Value: <%= @counter %></h3>
        <%= if @halting do %>
          <button disabled>Halting...</button>
        <% else %>
          <button phx-click="toggle-tick"><%= if @tick_time > 0 do %>Halt<% else %>Resume<% end %></button>
        <% end %>
      </div>
      <ul>
      <%= for past_step <- @past_steps do %>
        <li>On Step <%= elem(past_step, 0) %>, <%= elem(past_step, 1) %> moved <%= elem(past_step, 2) %></li>
      <% end %>
      </ul>
    </div>
    """
  end

  def handle_info(:tick, socket) do
    current_counter = socket.assigns.counter
    current_step = socket.assigns.step
    past_steps = socket.assigns.past_steps
    wobble = Enum.random(-3..3)

    last_nine_steps = Enum.take(past_steps, 9)
    updated_steps = [{current_step, current_counter, wobble} | last_nine_steps]

    socket =
      socket
      |> update(:step, &(&1 + 1))
      |> update(:counter, &(&1 + wobble))
      |> assign(halting: false)
      |> assign(past_steps: updated_steps)

    tick_time = socket.assigns.tick_time
    if tick_time > 0 do
      Process.send_after(self(), :tick, tick_time)
    end

    {:noreply, socket}
  end

  def handle_event("toggle-tick", _, socket) do
    tick_time = socket.assigns.tick_time

    cond do
      tick_time > 0 ->
        {:noreply, assign(socket, tick_time: -1, halting: true)}

      true ->
        Process.send_after(self(), :tick, @sec)
        {:noreply, assign(socket, tick_time: @sec)}
    end
  end
end
