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
  pipeline :authenticated_and_active do
    plug Guardian.AuthPipeline
    # plug for adding the current user in the connection
    plug Plugs.SessionPlug
    # plug fpor ensureing the user is active
    plug Plugs.IsActive
  end

  pipeline :authenticated_and_not_active do
    plug Guardian.AuthPipeline
    # plug for adding the current user in the connection
    plug Plugs.SessionPlug
  end

  scope "/api", EworksWeb do
    pipe_through :api

    post "/register", UserController, :register
    post "/login", SessionController, :login
  end

  scope "/api", EworksWeb do
    pipe_through [:api, :authenticated_and_not_active]

    post "/account/activate", UserController, :activate_account
    get "/account/activation/key/resend", UserController, :new_activation_key_request
  end



  # scope for the logged in user
  scope "/api", EworksWeb do
    pipe_through [:api, :authenticated_and_active]

    post "/user/profile/location", UserController, :update_user_profile_location
    post "/user/profile/emails", UserController, :update_user_profile_emails
    post "/user/profile/phones", UserController, :update_user_profile_phones
    post "/user/profile/picture", UserController, :update_user_profile_picture

    post "/work/profile/:work_profile_id/skills", UserController, :update_work_profile_skills
    post "/work/profile/:work_profile_id/intro", UserController, :update_work_profile_prof_intro
    post "/work/profile/:work_profile_id/letter", UserController, :update_work_profile_cover_letter

    # order routes
    get "/order/:order_id", OrderController, :get_order
    post "/order/new", OrderController, :create_new_order
    post "/order/:order_id/type", OrderController, :update_order_type_and_contractors
    post "/order/:order_id/payment", OrderController, :update_order_payment
    post "/order/:order_id/description", OrderController, :update_order_description
    post "/order/:order_id/duration", OrderController, :update_order_duration
    post "/order/:order_id/attachments", OrderController, :update_order_attachments
    get "/order/:order_id/verification/code", OrderController, :send_order_verification_code
    post "/order/:order_id/verify", OrderController, :verify_order

    # order offers
    post "/order/offer/:order_id/new", OrderController, :submit_order_offer
    post "/order/:order_id/offer/:order_offer_id/reject", OrderController, :reject_order_offer
    post "/order/:order_id/offer/:order_offer_id/accept", OrderController, :accept_order_offer
    post "/order/:order_id/assign/:to_assign_id", OrderController, :assign_order
    post "/order/:order_id/accept", OrderController, :accept_order
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
