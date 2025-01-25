defmodule HelloWeb.Router do
  use HelloWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HelloWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", HelloWeb do
    pipe_through :api
    get "/audit/:id", PageController, :test
    post "/audit/:id", PageController, :test

    # Scope for the users
    get "/users", UserController, :users
    # get "/users/:user_key", UserController, :user
    post "/users/create", UserController, :create_user

    # Scope for the api-keys
    get "/api_keys", KeyController, :api_keys
    post "/api_keys/create", KeyController, :create_api_key
  end

  scope "/", HelloWeb do
    pipe_through :browser

    get "/register", UserController, :register
    get "/login", UserController, :login
    post "/register", UserController, :create_user
    post "/login", UserController, :check_credentials
    get "/dashboard", PageController, :dashboard
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hello, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HelloWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
