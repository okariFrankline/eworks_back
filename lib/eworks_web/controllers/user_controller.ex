defmodule EworksWeb.Users.UserController do
  use EworksWeb, :controller

  import Ecto.Query, warn: false
  alias Eworks
  alias Eworks.Accounts.User
  alias Eworks.Utils.{Mailer, NewEmail}
  alias Eworks.{Repo, Orders, Accounts}


  action_fallback EworksWeb.FallbackController

  # alter the arity of the action functions
  def action(conn, _) do
    args = [conn, conn.params, Map.get(conn.assigns, :current_user)]
    # apply the funtcions
    apply(__MODULE__, action_name(conn), args)
  end # end of action


  @doc """
  Creates a new account using the details given by the user
  user params must include auth_email, password, and user_account
  """
  def register(conn, %{"user" => user_params}, _user) do
    # get the user type to determine which registration function to call
    user_type = if user_params["user_type"] == "Client", do: :client, else: :practise
    # create a new user and store a token for them
    with {:ok, %User{} = user} <- Eworks.register_user(user_type, user_params) do
      # Generate a new email
      # create a new activation code email
      NewEmail.new_activation_key_email(user, "Eworks Registration Confirmation", "Thank you for registering with Eworks. Here is your activation key. \n #{user.activation_key}")
      # send the email
      |> Mailer.deliver_later()

      # return a response
      conn
      #  put the status of created
      |> put_status(:created)
      # return the user details and the token
      |> render("new_user.json", user: user)
    end # end of with for creating a new user
  end # end of creation changeset

  @doc """
    Endpoint for activating a user's account
  """
  def activate_account(conn, %{"activation" => %{"activation_key" => key}}, user) do
    # actiate the account
    with {:ok, _user} <- Eworks.verify_account(user, key) do
      # return the result
      conn
      # put the okay status
      |> put_status(:ok)
      # render the loggedin.json
      |> render("success.json", message: "Success. Your account has been successfully activated.")
    end # end of with for verifying account
  end # end of the activate_account/2

  @doc """
  Returns the given user
  """
  def get_user(conn, _, user) do
    # return the results
    conn
    |> put_status(:ok)
    # render the results
    |> render("logged_in.json", user: user)
  end

  @doc """
    Updates the current user's location details
  """
  def update_user_profile_location(conn, %{"user_profile" => %{"location" => location_params}}, user) do
    with {:ok, _new_user} <- Eworks.update_user_profile_location(user, location_params) do
      conn
      # render the profiles view
      |> put_status(:ok)
      # send response
      |> render("success.json", message: "Success. Account detailed description successfully updated.")
    end # end of update the profile update
  end # end of the update_user_profile_location/2

  @doc """
    Updates the current user's work profile skills
  """
  def update_work_profile_skills(conn, %{"user_profile" => %{"new_skills" => new_skills}}, user) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # update the profile
    with {:ok, _work_profile} <- Eworks.update_work_profile_skills(user, profile, new_skills) do
      conn
      # put ok on the status
      |> put_status(:ok)
      # render the work profile
      |> render("success.json", message: "Success. SKills successfully updated.")
    end # end of with
  end # end of the uodate_work_profile_skills/2

  @doc """
    Updates the cover letter of a work profile
  """
  def update_work_profile_cover_letter(conn, %{"user_profile" => %{"cover_letter" => cover_letter}}, user) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # update the profile
    with {:ok, work_profile} <- Eworks.update_work_profile_cover_letter(user, profile, cover_letter) do
      conn
      # update the status
      |> put_status(:ok)
      # render the work profile
      |> render("work_profile.json", work_profile: work_profile, user: user)
    end # end of with
  end # end of the update the workprofile cover letter

  @doc """
    Updates the professional introduction of a work profile
  """
  def update_work_profile_prof_intro(conn, %{"user_profile" => %{"professional_intro" => prof_intro}}, user) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # update the profile
    with {:ok, _work_profile} <- Eworks.update_work_profile_prof_intro(user, profile, prof_intro) do
      conn
      # update the status
      |> put_status(:ok)
      # render the work profile
      |> render("success.json", message: "Success. Account detailed description successfully updated.")
    end # end of with
  end # end of the update the workprofile cover letter

  @doc """
    Requests a new activation key
  """
  def new_activation_key_request(conn, _params, user) do
    with {:ok, _user} <- Eworks.resend_activation_key(user) do
      conn
      # send the response
      |> put_status(:ok)
      # render success
      |> render("success.json", message: "Hello, #{user.full_name}, your new Activation key successfully sent to #{user.auth_email}.")
    end # end of send new activation request
  end # end of new activation key request

  @doc """
    Updates the profile picture of the current user
  """
  def update_user_profile_picture(conn, %{"profile_pic" => profile_picture_params}, user) do
    IO.inspect(profile_picture_params)
    # update the profile picture
    case Eworks.update_user_profile_picture(user, profile_picture_params) do
      {:ok, _user} ->
        conn
        # set the status to ok
        |> put_status(:ok)
        # render the user_profile
        |> render("success.json", message: "Success. Profile Image has been successfully updated.")

      {:error, _} ->
        conn
        # set the status to ok
        |> put_status(:bad_request)
        # add the error view
        |> put_view(EworksWeb.ErrorView)
        # render the user_profile
        |> render("failed.json", message: "Failed. Profile image could not be updated")
    end # end of with
  end # end of function for updating the profile picture

  @doc """
    Allows a client user to a temporary practise
  """
  def upgrade_client_to_practise(conn, %{"upgrade" => %{"upgrade_duration" => duration}}, user) do
    # upgrade a client information
    with {:ok, work_profile} <- Eworks.upgrade_client_to_practise(user, duration) do
      conn
      # set the status to created
      |> put_status(:ok)
      # render the user with the work profile
      |> render("upgraded_work_profile", work_profile: work_profile)
    end # end of with for upgrading the client to a practise
  end # end of upgrade_client_to_practise

  @doc """
    Allows user to change their password
  """
  def change_user_password(conn, %{"new_password" => password_params}, user) do
    with {:ok, _user} <- Eworks.change_password(user, password_params) do
      # return the response
      conn
      # put the status
      |> put_status(:ok)
      # render the success
      |> render("success.json", message: "Your password has been successfully changed.")
    end # end of password params
  end # end of change user password

  @doc """
    Function for changing the auth email
  """
  def change_auth_email(conn, %{"auth_email" => email}, user) do
    # check if the user with that given email address does not exitst
    if not Repo.exists?(from(user in User, where: user.auth_email == ^email)) do
      # change the email
      case Accounts.update_auth_email(user, %{auth_email: email}) do
        # the update was successfull
        {:ok, _user} ->
          # return a response
          conn
          # put status
          |> put_status(:ok)
          # render successs
          |> render("success.json", message: "Success. You have successfully updated your auth email.")

        {:error, _} ->
          # return a response
          conn
          # put status
          |> put_status(:bad_request)
          # put the error view
          |> put_view(EworksWeb.ErrorView)
          # render successs
          |> render("failed.json", message: "Failed. Auth email could not be updated. Please try again later.")
      end # end of case

    else # email is already in use
      # return a failed
       conn
       # put status
       |> put_status(:bad_request)
       # put the error view
       |> put_view(EworksWeb.ErrorView)
       # render successs
       |> render("failed.json", message: "Failed. The email address #{email} is already in use by another account.")
    end # end of if
  end # end of changing the auth email

   @doc """
    Function for changing the user's phone number
  """
  def change_user_phone(conn, %{"phone" => phone}, user) do
    # check if the user with that given email address does not exitst
    if not Repo.exists?(from(user in User, where: user.phone == ^phone)) do
      # change the email
      case Accounts.update_user_phone(user, %{phone: phone}) do
        # the update was successfull
        {:ok, _user} ->
          # return a response
          conn
          # put status
          |> put_status(:ok)
          # render successs
          |> render("success.json", message: "Success. You have successfully updated your phone number.")

        {:error, _} ->
          # return a response
          conn
          # put status
          |> put_status(:bad_request)
          # put the error view
          |> put_view(EworksWeb.ErrorView)
          # render successs
          |> render("failed.json", message: "Failed. Phone number could not be updated. Please try again later.")
      end # end of case

    else # email is already in use
      # return a failed
       conn
       # put status
       |> put_status(:bad_request)
       # put the error view
       |> put_view(EworksWeb.ErrorView)
       # render successs
       |> render("failed.json", message: "Failed. The phone number #{phone} is already in use by another account.")
    end # end of if
  end # end of changing the auth email

  @doc """
    Gets the user's offers
  """
  def get_user_offers(conn, %{"next_cursor" => after_cursor, "filter" => filter}, user) do
    # ensure the user is a contractor or if the user is a recently upgraded contractor
    if user.user_type == "Independent Contractor" or user.is_upgraded_contractor do
      # query for getting the offers
      query = from(
        offer in Eworks.Orders.OrderOffer,
        # ensure user id is is similar
        where: offer.user_id == ^user.id and offer.is_cancelled ==false,
        # order by the date of inserted
        order_by: [asc: offer.inserted_at, asc: offer.id],
        # join the user order
        join: order in assoc(offer, :order),
        # preload the order
        preload: [order: order]
      )

      # return a new query based on the filter
      query = case filter do
        "pending" ->
          from(offer in query, where: offer.is_pending == true)

        "accepted" ->
          from(offer in query, where: offer.is_accepted == true and offer.has_accepted_order == false)

        "rejected" ->
          from(offer in query, where: offer.is_rejected == true)
      end # end of query

      # check if the after_cursor is given
      page = if after_cursor == "false" do
        # get the offers
        Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 10)
      else
        # get the next page
        Repo.paginate(query, after: after_cursor, cursor_fields: [:inserted_at, :id], limit: 10)
      end # end of if

      # return the result
      conn
      # put the status
      |> put_status(:ok)
      # render he results
      |> render("offers.json", offers: page.entries, next_cursor: page.metadata.after)

    else
      # the user is a client
      conn
      # put status
      |> put_status(:forbidden)
      # put view
      |> put_view(EworksWeb.ErrorView)
      # render is client
      |> render("is_client.json", message: "Complete a One Time Upgrade and submit order offers then try again.")
    end # end of checking if the user is contractor
  end # end of get user

  @doc """
    Returns the profile of the current user
  """
  def get_user_profile(conn, _params, user) do
    # check the user type of the current user
    if user.user_type == "Independent Contractor" or user.is_upgraded_contractor do
      # load the work profile
      user = Repo.preload(user, [:work_profile])
      # get the previous hires
      previous_hires = load_previous_hires(user.work_profile.previous_hires)
      # return the result
      conn
      # put the status
      |> put_status(:ok)
      # render the profile
      |> render("contractor_profile.json", user: user, previous_hires: previous_hires)

    else
      # the user is a client
      # return the result
      conn
      # put the status
      |> put_status(:ok)
      # render the profile
      |> render("client_profile.json", user: user)
    end # end of checking the user type
  end # end of gettingthe user profile

  @doc """
    Returns the current user's saved contractors
  """
  def get_saved_contractors(conn, _params, user) do
    users = if not Enum.empty?(user.saved_workers) do
      # create a dataloader
      Dataloader.new()
      # set the data source
      |> Dataloader.add_source(Accounts, Accounts.data())
      # load the users
      |> Dataloader.load_many(Accounts, Accounts.User, user.saved_workers)
      # run the dataloader
      |> Dataloader.run()
      # get the users
      |> Dataloader.get_many(Accounts, Accounts.User, user.saved_workers)
    else
      # return an empty list
      []
    end # end of if for getting the workers

    conn
    # put the status
    |> put_status(:ok)
    # render the saved workers
    |> render("saved_workers.json", users: users)
  end # end of get_saved_contractors

  @doc """
    One time account upgrade
  """
  def one_time_upgrade(conn, %{"upgrade_data" => %{"length" => duration, "phone" => phone}}, user) do
    with {:ok, _user} <- Eworks.one_time_upgrade(user, duration, phone) do
      conn
      |> put_status(:ok)
      |> render("success.json", message: "Received: Phone: #{phone} and Length: #{duration}")
    end
  end # end of one time upgrade


  ## function for loading the previous hires
  defp load_previous_hires(ids) when ids == [], do: []
  # when the ids are not empaty
  defp load_previous_hires(ids) do
    Dataloader.new
    # add the source
    |> Dataloader.add_source(Orders, Orders.data())
    # load the orders
    |> Dataloader.load_many(Orders, Orders.Order, ids)
    # run the loader
    |> Dataloader.run()
    # get the results
    |> Dataloader.get_many(Orders, Orders.Order, ids)
  end # end of load previous hires

end # end of the module
