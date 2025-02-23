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

  scope "/", HelloWeb do
    pipe_through :browser

    get "/register", UserController, :register
    get "/login", UserController, :login
    get "/auth", UserController, :auth
    post "/register", UserController, :create_user
    post "/login", UserController, :check_credentials
    get "/", PageController, :dashboard
    get "/dashboard", PageController, :dashboard
  end

  scope "/v1", HelloWeb do
    pipe_through :api

    post "/audit", AuditController, :doAudit
  end

  scope "/v1/users", HelloWeb do
    pipe_through :api

    get "/", UserController, :users
    post "/create", UserController, :create_user
  end

  scope "/v1/api_keys", HelloWeb do
    pipe_through :api

    get "/", KeyController, :api_keys
    get "/:uuid", KeyController, :api_keys_by_uuid
    post "/create", KeyController, :create_api_key
    delete "/:id", KeyController, :delete_api_key
  end

  scope "/v1/projects", HelloWeb do
    pipe_through :api

    # get "/:uuid", UserController, :users
    post "/create", ProjectController, :create_project
    get "/all/:uuid", ProjectController, :get_projects
    get "/:uuid", ProjectController, :get_project
    post "/:uuid/add_member", ProjectController, :add_member
    post "/:uuid/delete_member", ProjectController, :delete_member
    post "/:uuid/add_issue", ProjectController, :add_issue
    post "/:uuid/delete", ProjectController, :delete_project
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
