defmodule EworksWeb.Router do
  use EworksWeb, :router
  alias EworksWeb.Authentication.Guardian
  alias EworksWeb.Plugs

  pipeline :api do
    plug :accepts, ["json"]
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Jason
  end

  # define an auth pipeline
  pipeline :authenticated do
    plug Guardian.AuthPipeline
    # plug for adding the current user in the connection
    plug Plugs.SessionPlug
  end

  scope "/api", EworksWeb do
    pipe_through :api

    post "/register", UserController, :register
    post "/login", SessionController, :login
  end

  # scope for the logged in user
  scope "/api", EworksWeb do
    pipe_through [:api, :authenticated]

    post "/activate", UserController, :activate_account
    post "/profile/:profile_id/location", UserController, :update_user_profile_location
    post "/profile/:profile_id/emails", UserController, :update_user_profile_emails
    post "/profile/:profile_id/phones", UserController, :update_user_profile_phones
  end # end of scope for logged in users

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: EworksWeb.Telemetry
    end
  end
end
