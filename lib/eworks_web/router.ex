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

  # define an auth pipeline
  pipeline :authenticated do
    plug Guardian.AuthPipeline
    # plug for adding the current user in the connection
    plug Plugs.SessionPlug
  end

  pipeline :authenticated_and_not_active do
    plug Guardian.AuthPipeline
    # plug for adding the current user in the connection
    plug Plugs.SessionPlug
  end

  scope "/api", EworksWeb do
    pipe_through :api

    post "/account/register", UserController, :register
    post "/account/login", SessionController, :login
  end

  scope "/api", EworksWeb do
    pipe_through [:api, :authenticated]

    get "/account/user", UserController, :get_user
    post "/account/logout", SessionController, :logout
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
    post "/user/change/password", UserController, :change_user_password
    get "/user/new/activation", UserController, :new_activation_key_request

    post "/work/profile/:work_profile_id/skills", UserController, :update_work_profile_skills
    post "/work/profile/:work_profile_id/intro", UserController, :update_work_profile_prof_intro
    post "/work/profile/:work_profile_id/letter", UserController, :update_work_profile_cover_letter

    # order routes
    get "/order/:order_id", OrderListController, :get_order
    get "/order/:order_id/verification/code", OrderController, :send_order_verification_code
    get "/order/:order_id/resend/verification/code", OrderController, :resend_order_verification_code
    post "/order/new", OrderController, :create_new_order
    post "/order/:order_id/category", OrderController, :update_order_category
    post "/order/:order_id/type", OrderController, :update_order_type_and_contractors
    post "/order/:order_id/payment", OrderController, :update_order_payment
    post "/order/:order_id/description", OrderController, :update_order_description
    post "/order/:order_id/duration", OrderController, :update_order_duration
    post "/order/:order_id/attachments", OrderController, :update_order_attachments
    post "/order/:order_id/verify", OrderController, :verify_order
    post "/order/:order_id/tag", OrderController, :tag_order
    post "/order/:order_id/cancel", OrderController, :cancel_order

    # order offers
    post "/order/offer/:order_id/new", OrderController, :submit_order_offer
    post "/order/:order_id/offer/:order_offer_id/reject", OrderController, :reject_order_offer
    post "/order/:order_id/offer/:order_offer_id/accept", OrderController, :accept_order_offer
    post "/order/:order_id/assign/:to_assign_id", OrderController, :assign_order
    post "/order/:order_id/accept/:order_offer_id", OrderController, :accept_order
    post "/order/offer/:order_offer_id/cancel", OrderController, :cancel_order_offer
    post "/order/:order_id/reject/:order_offer_id", OrderController, :reject_order

    # invites
    post "/invite/:order_id/new", InviteController, :create_new_invite
    post "/invite/:invite_id/payment", InviteController, :update_invite_payment
    post "/invite/offer/:invite_id/new", InviteController, :submit_invite_offer
    post "/invite/:invite_id/offer/:invite_offer_id/reject", InviteController, :reject_invite_offer
    post "/invite/:invite_id/offer/:invite_offer_id/accept", InviteController, :accept_invite_offer
    post "/invite/:invite_id/cancel", InviteController, :cancel_invite
    post "/invite/offer/:invite_offer_id/cancel", InviteController, :cancel_invite_offer

    # direct hire
    get "/direct/hire/client", DirectHireController, :list_client_direct_hires
    get "/direct/hire/contractor", DirectHireController, :list_contractor_direct_hires
    post "/direct/hire/:order_id/contractor/:contractor_id/new", DirectHireController, :create_new_direct_hire_request
    post "/direct/hire/:direct_hire_id/accept", DirectHireController, :accept_direct_hire_request
    post "/direct/hire/:direct_hire_id/reject", DirectHireController, :reject_direct_hire_request
    post "/direct/hire/:direct_hire_id/assign", DirectHireController, :assign_order_from_direct_hire

    # get
    get "/orders/unassigned", OrderListController, :list_unassigned_orders
    get "/user/orders/created", OrderListController, :list_current_user_created_orders
    get "/contractors", WorkersController, :list_workers
    get "/contractors/search", WorkersController, :search_based_on_skill
    get "/contractors/saved", WorkersController, :list_saved_workers
    post "/contractors/:contractor_id/save", WorkersController, :save_worker
    post "/contractors/:contractor_id/unsave", WorkersController, :unsave_worker

    # contractors
    get "/contractors/:contractor_id", WorkersController, :get_contractor
    # get user offers
    get "/user/offers", UserController, :get_user_offers

  end # end of scope for logged in users

  # Enables LiveDashboard only for development
  #assign_order_from_direct_hire
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
