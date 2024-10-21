defmodule SkillcheckerWeb.Router do
  use SkillcheckerWeb, :router

  import SkillcheckerWeb.AdminAuth
  alias SkillcheckerWeb.RequireAcceptedAdmin

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SkillcheckerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
    plug PlugClacks
  end

  pipeline :unlogged do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SkillcheckerWeb.Layouts, :unlogged}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
    plug PlugClacks
  end

  pipeline :character do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SkillcheckerWeb.Layouts, :character}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PlugClacks
  end

  pipeline :require_accepted_admin do
    plug RequireAcceptedAdmin
  end

  scope "/", SkillcheckerWeb do
    pipe_through :unlogged

    get "/", PageController, :user_landing
    get "/waiting/:id", PageController, :user_waiting
  end

  scope "/admin", SkillcheckerWeb do
    pipe_through [:unlogged, :redirect_if_admin_is_authenticated]

    get "/", PageController, :admin_landing
    get "/waiting", PageController, :admin_waiting
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:skillchecker, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SkillcheckerWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", SkillcheckerWeb do
    pipe_through [:unlogged, :redirect_if_admin_is_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      on_mount: [{SkillcheckerWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/admin/register", AdminUnloggedLive.Register, :new
      live "/admin/log_in", AdminUnloggedLive.Login, :new
    end

    post "/admin/log_in", AdminSessionController, :create
  end

  scope "/admin/", SkillcheckerWeb do
    pipe_through [:browser, :require_authenticated_admin, :require_accepted_admin]

    live_session :require_authenticated_admin,
      on_mount: [{SkillcheckerWeb.AdminAuth, :ensure_authenticated}] do

      live "/dashboard", DashboardLive.Dashboard, :dashboard
      live "/dashboard/characters/:id/edit", DashboardLive.Dashboard, :edit_character
      live "/dashboard/admins/:id/edit", DashboardLive.Dashboard, :edit_admin

      live "/settings", AdminLive.Settings, :edit

      live "/admins", AdminLive.Index, :index
      live "/admins/new", AdminLive.Index, :new
      live "/admins/:id/edit", AdminLive.Index, :edit

      live "/admins/:id", AdminLive.Show, :show
      live "/admins/:id/show/edit", AdminLive.Show, :edit

      live "/skillsets", SkillsetLive.Index, :index
      live "/skillsets/new", SkillsetLive.Index, :new
      live "/skillsets/:id/edit", SkillsetLive.Index, :edit

      live "/skillsets/:id", SkillsetLive.Show, :show
      live "/skillsets/:id/show/edit", SkillsetLive.Show, :edit

      live "/characters", CharacterLive.Index, :index
      live "/characters/new", CharacterLive.Index, :new
      live "/characters/:id/edit", CharacterLive.Index, :edit

      live "/characters/:id", CharacterLive.Show, :show
      live "/characters/:id/show/edit", CharacterLive.Show, :edit
      live "/characters/:id/refresh", CharacterLive.Refresh, :refresh

      live "/stats/attendance", StatsLive.Attendance, :attendance
    end

  end

  scope "/", SkillcheckerWeb do
    pipe_through :browser

    delete "/admin/log_out", AdminSessionController, :delete
  end

  scope "/auth", SkillcheckerWeb do
    pipe_through :browser

    # sso methods
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/", SkillcheckerWeb do
    pipe_through :character

    get "/characters/:id", CharacterController, :show
  end
end
