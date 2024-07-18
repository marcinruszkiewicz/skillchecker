defmodule SkillcheckerWeb.Router do
  use SkillcheckerWeb, :router

  import SkillcheckerWeb.AdminAuth

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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SkillcheckerWeb do
    pipe_through :unlogged

    get "/", PageController, :user_landing
  end

  scope "/admin", SkillcheckerWeb do
    pipe_through [:unlogged, :redirect_if_admin_is_authenticated]

    get "/", PageController, :admin_landing
  end

  # Other scopes may use custom stacks.
  # scope "/api", SkillcheckerWeb do
  #   pipe_through :api
  # end

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
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SkillcheckerWeb do
    pipe_through [:unlogged, :redirect_if_admin_is_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      on_mount: [{SkillcheckerWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/admin/register", AdminUnloggedLive.Register, :new
      live "/admin/log_in", AdminUnloggedLive.Login, :new
      live "/admin/reset_password", AdminUnloggedLive.Forgot, :new
      live "/admin/reset_password/:token", AdminResetPasswordLive, :edit
    end

    post "/admin/log_in", AdminSessionController, :create
  end

  scope "/admin/", SkillcheckerWeb do
    pipe_through [:browser, :require_authenticated_admin]

    get "/dashboard", PageController, :admin_dashboard

    live_session :require_authenticated_admin,
      on_mount: [{SkillcheckerWeb.AdminAuth, :ensure_authenticated}] do
      live "/settings", AdminLive.Settings, :edit
      live "/settings/confirm_email/:token", AdminLive.Settings, :confirm_email

      live "/admins", AdminLive.Index, :index
      live "/admins/new", AdminLive.Index, :new
      live "/admins/:id/edit", AdminLive.Index, :edit

      live "/admins/:id", AdminLive.Show, :show
      live "/admins/:id/show/edit", AdminLive.Show, :edit
    end

  end

  scope "/", SkillcheckerWeb do
    pipe_through [:browser]

    delete "/admin/log_out", AdminSessionController, :delete

    live_session :current_admin,
      on_mount: [{SkillcheckerWeb.AdminAuth, :mount_current_admin}] do
      live "/admin/confirm/:token", AdminConfirmationLive, :edit
      live "/admin/confirm", AdminConfirmationInstructionsLive, :new
    end
  end
end
