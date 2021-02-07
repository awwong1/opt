defmodule OptWeb.CounterLive do
  require Logger
  use OptWeb, :live_view

  def mount(_params, _session, socket) do
    Logger.debug "#{inspect self()} CounterLive.mount/3"
    socket = assign(socket, :counter, 10)
    {:ok, socket}
  end

  def render(assigns) do
    Logger.debug "#{inspect self()} CounterLive.render/1"
    ~L"""
    <div id="counter" class="phx-hero">
      <h1>Simple Counter</h1>
      <h2><%= @counter %>/100</h2>

      <div>
        <button phx-click="off">Clear</button>
        <button phx-click="up">+10</button>
        <button phx-click="rand">Random</button>
        <button phx-click="down">-10</button>
        <button phx-click="on">Max</button>
      </div>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :counter, 100)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :counter, 0)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    # counter = socket.assigns.counter + 10
    # socket = assign(socket, :counter, counter)
    socket = update(socket, :counter, &(min(&1 + 10, 100)))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    {:noreply, update(socket, :counter, &(max(&1 - 10, 0)))}
  end

  def handle_event("rand", _, socket) do
    val = :rand.uniform(100)
    socket = assign(socket, :counter, val)
    {:noreply, socket}
  end
end
