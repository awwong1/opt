defmodule OptWeb.Router do
  use OptWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OptWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OptWeb do
    pipe_through :browser

    # get "/", PageController, :index
    live "/", PageLive, :index

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  scope "/api", OptWeb do
    pipe_through :api
    # , except: [:new, :edit]
    resources "/users", UserController
    # , except: [:new, :edit]
    resources "/emails", EmailController
  end

  import Phoenix.LiveDashboard.Router
  # no authentication, publicly visible default dashboard
  # if Mix.env() == :dev do
  scope "/" do
    pipe_through :browser
    live_dashboard "/dashboard", metrics: OptWeb.Telemetry
  end

  # end
end
