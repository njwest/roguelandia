defmodule LiveArenaWeb.Router do
  use LiveArenaWeb, :router

  import LiveArenaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveArenaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveArenaWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveArenaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:live_arena, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LiveArenaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LiveArenaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LiveArenaWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserLive.UserRegistrationLive, :new
      live "/users/log_in", UserLive.UserLoginLive, :new
      live "/users/reset_password", UserLive.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserLive.UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LiveArenaWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LiveArenaWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserLive.UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserLive.UserSettingsLive, :confirm_email
    end
  end

  scope "/", LiveArenaWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LiveArenaWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserLive.UserConfirmationLive, :edit
      live "/users/confirm", UserLive.UserConfirmationInstructionsLive, :new
    end
  end
end
