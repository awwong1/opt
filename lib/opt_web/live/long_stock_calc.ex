defmodule OptWeb.LongStockCalcLive do
  require Logger
  use OptWeb, :live_view

  import Number.Currency

  def mount(_params, _session, socket) do
    socket = assign(socket, ticker_symbol: "XYZ", stock_price: 18.75, stock_amount: 10)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="long-call-calc">
      <h1>Simple Long Stock Calculator</h1>

      <h3>
        Purchased <%= @stock_amount %> <%= @ticker_symbol %> at <%= number_to_currency(@stock_price) %> for <%= number_to_currency(@stock_price * @stock_amount) %>.
      </h3>

      <form phx-change="update">
        <label for="ticker_symbol">Ticker Symbol:</label>
        <input
          type="text"
          name="ticker_symbol"
          value="<%= @ticker_symbol %>"
        />

        <label for="stock_price">Stock Price:</label>
        <input
          name="stock_price"
          type="number"
          value="<%= @stock_price %>"
          step="0.25"
          min="0.00"
        />

        <label for="stock_amount">Number of Shares:</label>
        <input
          min="1"
          type="number"
          name="stock_amount"
          value="<%= @stock_amount %>"
          pattern="\d+"
        />
      </form>

    </div>
    """
  end

  def handle_event(
        "update",
        %{
          "ticker_symbol" => ticker_symbol,
          "stock_price" => raw_stock_price,
          "stock_amount" => raw_stock_amount
        },
        socket
      ) do
    stock_price =
      case Float.parse(raw_stock_price) do
        {stock_price, _} -> stock_price
        :error -> 0
      end

    stock_amount =
      case Integer.parse(raw_stock_amount) do
        {stock_amount, _} -> stock_amount
        :error -> 0
      end

    socket =
      assign(socket,
        ticker_symbol: ticker_symbol,
        stock_price: stock_price,
        stock_amount: stock_amount
      )

    {:noreply, socket}
  end
end
