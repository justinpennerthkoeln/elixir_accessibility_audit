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
    get "/auth", UserController, :check_credentials
    post "/register", UserController, :create_user
    post "/login", UserController, :check_credentials
    get "/", PageController, :dashboard
    get "/dashboard", PageController, :dashboard
  end

  scope "/v1", HelloWeb do
    pipe_through :api

    post "/audit", AuditController, :doAudit

    post "/pdf/gen_audit", PdfController, :generate_audit_pdf
    post "/pdf/gen_project", PdfController, :generate_project_pdf
    post "/pdf/gen_single_issue", PdfController, :generate_single_issue_pdf
    get "/pdf/:name", PdfController, :pdf

    get "/users", UserController, :users
    post "/users/create", UserController, :create_user

    get "/api_keys", KeyController, :api_keys
    get "/api_keys/:uuid", KeyController, :api_keys_by_uuid
    post "/api_keys/create", KeyController, :create_api_key
    delete "/api_keys/:id", KeyController, :delete_api_key

    post "/projects/create", ProjectController, :create_project
    get "/projects/all/:uuid", ProjectController, :get_projects
    get "/projects/:uuid", ProjectController, :get_project
    post "/projects/:uuid/add_member", ProjectController, :add_member
    post "/projects/:uuid/delete_member", ProjectController, :delete_member
    post "/projects/:uuid/add_issue", ProjectController, :add_issue
    post "/projects/:uuid/delete", ProjectController, :delete_project

    post "/issues/:uuid/delete", IssueController, :delete_issue
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
