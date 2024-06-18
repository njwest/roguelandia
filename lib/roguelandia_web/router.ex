defmodule RoguelandiaWeb.Router do
  use RoguelandiaWeb, :router

  import RoguelandiaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RoguelandiaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", RoguelandiaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:roguelandia, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RoguelandiaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", RoguelandiaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
    live "/", UserLive.UserLoginLive, :new

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{RoguelandiaWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserLive.UserRegistrationLive, :new
      live "/users/log_in", UserLive.UserLoginLive, :new
      live "/users/reset_password", UserLive.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserLive.UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", RoguelandiaWeb do
    pipe_through [:browser, :require_authenticated_user]
    live_session :require_authenticated_user,
      on_mount: [{RoguelandiaWeb.UserAuth, :ensure_authenticated}] do
      live "/lobby", LobbyLive, :lobby

      live "/battle/", BattleLive, :battle
      live "/battles/:battle_id", GameOverLive, :battle


      live "/users/settings", UserLive.UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserLive.UserSettingsLive, :confirm_email

      live "/bosses", BossLive.Index, :index
      live "/bosses/new", BossLive.Index, :new
      live "/bosses/:id/edit", BossLive.Index, :edit

      live "/bosses/:id", BossLive.Show, :show
      live "/bosses/:id/show/edit", BossLive.Show, :edit

      live "/classes", ClassLive.Index, :index
      live "/classes/new", ClassLive.Index, :new
      live "/classes/:id/edit", ClassLive.Index, :edit

      live "/classes/:id", ClassLive.Show, :show
      live "/classes/:id/show/edit", ClassLive.Show, :edit
    end
  end

  scope "/", RoguelandiaWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{RoguelandiaWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserLive.UserConfirmationLive, :edit
      live "/users/confirm", UserLive.UserConfirmationInstructionsLive, :new
    end
  end
end
