defmodule OptWeb.Router do
  use OptWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OptWeb do
    pipe_through :browser

    get "/", PageController, :index
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
    live_dashboard "/dashboard"
  end
  # end
end
