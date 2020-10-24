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

  # scopre for account login and registration
  scope "/api", EworksWeb do
    pipe_through :api

    post "/account/register", Users.UserController, :register
    post "/account/login", SessionController, :login
  end

  scope "/api", EworksWeb do
    pipe_through [:api, :authenticated]

    get "/account/user", Users.UserController, :get_user
    post "/account/logout", SessionController, :logout
  end

  scope "/api", EworksWeb do
    pipe_through [:api, :authenticated_and_not_active]

    post "/account/activate", Users.UserController, :activate_account
    get "/account/activation/key/resend", Users.UserController, :new_activation_key_request
  end


  # scope for the invites
  scope "/api/invites", EworksWeb.Invites do
    # ensure user is logged in and is active
    pipe_through [:api, :authenticated_and_active]

    ########################################## INVITE GET ROUTES###################################################

    # invite for getting unassigned invites
    get "/unassigned", InviteController, :list_unassigned_invites
    # invite for getting invites created by the current user
    get "/created", InviteController, :list_invites_created_by_current_user
    # route for getting invite offers created by current user
    get "/offers", InviteController, :list_current_user_invite_offers
    # route for getting a verification code
    get "/:invite_id/verification", InviteController, :get_verification_code
    # route for resending a verification code
    get "/:invite_id/verification/resend", InviteController, :resend_verification_code
    # gets a single invite
    get "/:invite_id", InviteController, :get_invite

   ########################################## INVITE POST ROUTES###################################################
    # route for creating a new invite
    post "/:order_id/new", InviteController, :create_new_invite
    # invite for updating the invite payment
    post "/:invite_id/category", InviteController, :update_invite_category
    # invite for updating the invite payment
    post "/:invite_id/payment", InviteController, :update_invite_payment
    # invite for updating the description
    post "/:invite_id/description", InviteController, :update_invite_description
    # invite for updating the description
    post "/:invite_id/deadline", InviteController, :update_invite_deadline_collaborators
    # route for verifying an invite
    post "/:invite_id/verify", InviteController, :verify_invite
    # route for creating a new invite
    post "/offer/:invite_id/new", InviteController, :submit_invite_offer
    # route for rejecting an invite offer
    post "/:invite_id/offer/:invite_offer_id/reject", InviteController, :reject_invite_offer
    # route for accepting an invite offer
    post "/:invite_id/offer/:invite_offer_id/accept", InviteController, :accept_invite_offer
    # route for cancelling an invite
    post "/:invite_id/cancel", InviteController, :cancel_invite
    # route for cancelling an invite offer
    post "/offer/:invite_offer_id/cancel", InviteController, :cancel_invite_offer

  end # end of invite scope

  # scope for users
  scope "/api/user", EworksWeb.Users do
    # ensure user is authenticated and active
    pipe_through [:api, :authenticated_and_active]

    ######################################## GET ROUTES ################################
    # get user offers
    get "/offers", UserController, :get_user_offers
    # sends new user action key
    get "/new/activation", UserController, :new_activation_key_request

    ######################################## POST ROUTES ###############################
    # updates the current user's location information
    post "/profile/location", UserController, :update_user_profile_location
    # updates the current user's email information
    post "/profile/emails", UserController, :update_user_profile_emails
    # updates the current user's phone numbers
    post "/profile/phones", UserController, :update_user_profile_phones
    # updates the current user's profile picture
    post "/profile/picture", UserController, :update_user_profile_picture
    # updates the current user's password
    post "/change/password", UserController, :change_user_password
    # updates the work profile skills of the current user
    post "/work/profile/:work_profile_id/skills", UserController, :update_work_profile_skills
    # updates the intro of the current user
    post "/work/profile/:work_profile_id/intro", UserController, :update_work_profile_prof_intro
    # updates the cover letter of the current user
    post "/work/profile/:work_profile_id/letter", UserController, :update_work_profile_cover_letter

  end # end of users' scope

  # scope for order
  scope "/api/order", EworksWeb.Orders do
    # ensure user is logged in and active
    pipe_through [:api, :authenticated_and_active]

    ################################### GET ROUTES #####################################
    # returns a single order with a given id
    get "/:order_id", OrderController, :get_order
    # returns a list of the offers for a given order
    get "/:order_id/offers", OrderController, :list_order_offers
    # returns the list of assignees for a given order
    get "/:order_id/assignees", OrderController, :list_order_assignees
    # gets the verification for the given order
    get "/:order_id/verification", OrderController, :send_order_verification_code
    # resends the order verification code
    get "/order/:order_id/verification/resend", OrderController, :resend_order_verification_code

    ##################################### POST ROUTES ################################################
    # creates a new order
    post "/new", OrderController, :create_new_order
    # updates the order's category
    post "/:order_id/category", OrderController, :update_order_category
    # updates the order's type
    post "/:order_id/type", OrderController, :update_order_type_and_contractors
    post "/:order_id/payment", OrderController, :update_order_payment
    # updates the order's description
    post "/:order_id/description", OrderController, :update_order_description
    # updates the order's duration
    post "/:order_id/duration", OrderController, :update_order_duration
    # updates the order's attachments
    post "/:order_id/attachments", OrderController, :update_order_attachments
    # verifies an order
    post "/:order_id/verify", OrderController, :verify_order
    # tags an order
    post "/:order_id/tag", OrderController, :tag_order
    # cancels an order
    post "/:order_id/cancel", OrderController, :cancel_order
    # creates a new offer for agiven order
    post "/offer/:order_id/new", OrderController, :submit_order_offer
    # rejects an offer for a given order
    post "/:order_id/offer/:order_offer_id/reject", OrderController, :reject_order_offer
    # accepts an offer fr a given order
    post "/:order_id/offer/:order_offer_id/accept", OrderController, :accept_order_offer
    # assigns a given order
    post "/:order_id/assign/:to_assign_id", OrderController, :assign_order
    # accepts an order
    post "/:order_id/accept/:order_offer_id", OrderController, :accept_order
    # cancels a given order
    post "/offer/:order_offer_id/cancel", OrderController, :cancel_order_offer
    # rejects an order
    post "/:order_id/reject/:order_offer_id", OrderController, :reject_order
    # marks an order as complete
    post "/:order_id/complete", OrderController, :mark_order_complete
  end # end of order's scope


  # scope for the logged in user
  scope "/api", EworksWeb do
    pipe_through [:api, :authenticated_and_active]

    # post "/user/profile/location", UserController, :update_user_profile_location
    # post "/user/profile/emails", UserController, :update_user_profile_emails
    # post "/user/profile/phones", UserController, :update_user_profile_phones
    # post "/user/profile/picture", UserController, :update_user_profile_picture
    # post "/user/change/password", UserController, :change_user_password
    # get "/user/new/activation", UserController, :new_activation_key_request

    # post "/work/profile/:work_profile_id/skills", UserController, :update_work_profile_skills
    # post "/work/profile/:work_profile_id/intro", UserController, :update_work_profile_prof_intro
    # post "/work/profile/:work_profile_id/letter", UserController, :update_work_profile_cover_letter

    # order routes
    # get "/order/:order_id", OrderListController, :get_order
    # get "/order/:order_id/verification/code", OrderController, :send_order_verification_code
    # get "/order/:order_id/resend/verification/code", OrderController, :resend_order_verification_code
    # post "/order/new", OrderController, :create_new_order
    # post "/order/:order_id/category", OrderController, :update_order_category
    # post "/order/:order_id/type", OrderController, :update_order_type_and_contractors
    # post "/order/:order_id/payment", OrderController, :update_order_payment
    # post "/order/:order_id/description", OrderController, :update_order_description
    # post "/order/:order_id/duration", OrderController, :update_order_duration
    # post "/order/:order_id/attachments", OrderController, :update_order_attachments
    # post "/order/:order_id/verify", OrderController, :verify_order
    # post "/order/:order_id/tag", OrderController, :tag_order
    # post "/order/:order_id/cancel", OrderController, :cancel_order

    # # order offers
    # post "/order/offer/:order_id/new", OrderController, :submit_order_offer
    # post "/order/:order_id/offer/:order_offer_id/reject", OrderController, :reject_order_offer
    # post "/order/:order_id/offer/:order_offer_id/accept", OrderController, :accept_order_offer
    # post "/order/:order_id/assign/:to_assign_id", OrderController, :assign_order
    # post "/order/:order_id/accept/:order_offer_id", OrderController, :accept_order
    # post "/order/offer/:order_offer_id/cancel", OrderController, :cancel_order_offer
    # post "/order/:order_id/reject/:order_offer_id", OrderController, :reject_order
    # post "/order/:order_id/complete", OrderController, :mark_order_complete

    # invites
    # post "/invite/:order_id/new", InviteController, :create_new_invite
    # post "/invite/:invite_id/payment", InviteController, :update_invite_payment
    # post "/invite/:invite_id/description", InviteController, :update_invite_description
    # post "/invite/:invite_id/deadline", InviteController, :update_invite_deadline_collaborators
    # post "/invite/offer/:invite_id/new", InviteController, :submit_invite_offer
    # post "/invite/:invite_id/offer/:invite_offer_id/reject", InviteController, :reject_invite_offer
    # post "/invite/:invite_id/offer/:invite_offer_id/accept", InviteController, :accept_invite_offer
    # post "/invite/:invite_id/cancel", InviteController, :cancel_invite
    # post "/invite/offer/:invite_offer_id/cancel", InviteController, :cancel_invite_offer

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
    get "/user/orders/assigned", OrderListController, :list_orders_assigned_to_current_user
    get "/contractors", WorkersController, :list_workers
    get "/contractors/search", WorkersController, :search_based_on_skill
    get "/contractors/saved", WorkersController, :list_saved_workers
    post "/contractors/:contractor_id/save", WorkersController, :save_worker
    post "/contractors/:contractor_id/unsave", WorkersController, :unsave_worker

    # contractors
    get "/contractors/:contractor_id", WorkersController, :get_contractor
    # get user offers
    #get "/user/offers", UserController, :get_user_offers

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
