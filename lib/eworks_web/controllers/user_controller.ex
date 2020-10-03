defmodule EworksWeb.UserController do
  use EworksWeb, :controller

  alias Eworks
  alias Eworks.Accounts.User
  alias Eworks.Utils.{Mailer, NewEmail}
  alias EworksWeb.{Authentication, Plugs}

  @work_profile_actions ~w(update_work_profile_skills update_work_profile_cover_letter update_work_profile_prof_intro)a

  plug Plugs.WorkProfileById when action in @work_profile_actions


  action_fallback EworksWeb.FallbackController

  # alter the arity of the action functions
  def action(conn, _) do
    args = if action_name(conn) in @work_profile_actions do
      # return th args including the current user and the work profile
      [conn, conn.params, Map.get(conn.assigns, :current_user), conn.assigns.work_profile]
    else
      # returns the arg with only the current user
      [conn, conn.params, Map.get(conn.assigns, :current_user)]
    end # end of if
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
    with {:ok, %User{} = user} <- Eworks.register_user(user_type, user_params), {:ok, jwt} <- Authentication.create_token(user) do
      # Generate a new email
      NewEmail.new_activation_email(user)
      # send the email
      |> Mailer.deliver_later()

      # return a response
      conn
      #  put the status of created
      |> put_status(:created)
      # return the user details and the token
      |> render("new_user.json", user: user, token: jwt)
    end # end of with for creating a new user
  end # end of creation changeset

  @doc """
    Endpoint for activating a user's account
  """
  def activate_account(conn, %{"activation" => %{"activation_key" => key}}, user) do
    # actiate the account
    with {:ok, user} <- Eworks.verify_account(user, key) do
      if user.user_type == "Client" do
        # return the result
        conn
        # put the okay status
        |> put_status(:ok)
        # render the loggedin.json
        |> render("profile.json", user: user)
      else
        # the user is a practise
        # return the result
        conn
        # put the okay status
        |> put_status(:ok)
        # render the loggedin.json
        |> render("practise_profile.json", user: user)
      end
    end # end of with for verifying account
  end # end of the activate_account/2

  @doc """
    Updates the current user's location details
  """
  def update_user_profile_location(conn, %{"user_profile" => %{"location" => location_params}}, user) do
    with {:ok, new_user} <- Eworks.update_user_profile_location(user, location_params) do
      conn
      # put an ok status
      |> put_status(:ok)
      # render the profiles view
      |> render("profile.json", user: new_user)
    end # end of update the profile update
  end # end of the update_user_profile_location/2

  @doc """
    Updates the email address of the current user
  """
  def update_user_profile_emails(conn, %{"user_profile" => %{"new_email" => new_email}}, user) do
    with {:ok, user} <- Eworks.update_user_profile_emails(user, new_email) do
      conn
      # put ok on the status
      |> put_status(:ok)
      # render the profiles view
      |> render("profile.json", user: user)
    end # end of the updating the emails
  end # end of the update_user_profile_emails

  @doc """
    Updates the phone number of the current user
  """
  def update_user_profile_phones(conn, %{"user_profile" => %{"new_phone" => new_phone}}, user) do
    with {:ok, user} <- Eworks.update_user_profile_phones(user, new_phone) do
      conn
      # put ok on the status
      |> put_status(:ok)
      # render the profiles view
      |> render("profile.json", user: user)
    end # end of the updating the emails
  end # end of the update_user_profile_emails

  @doc """
    Updates the current user's work profile skills
  """
  def update_work_profile_skills(conn, %{"work_profile" => %{"new_skills" => new_skills}}, user, work_profile) do
    with {:ok, work_profile} <- Eworks.update_work_profile_skills(user, work_profile, new_skills) do
      conn
      # put ok on the status
      |> put_status(:ok)
      # render the work profile
      |> render("work_profile.json", work_profile: work_profile, user: user)
    end # end of with
  end # end of the uodate_work_profile_skills/2

  @doc """
    Updates the cover letter of a work profile
  """
  def update_work_profile_cover_letter(conn, %{"work_profile" => %{"cover_letter" => cover_letter}}, user, work_profile) do
    with {:ok, work_profile} <- Eworks.update_work_profile_cover_letter(user, work_profile, cover_letter) do
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
  def update_work_profile_prof_intro(conn, %{"work_profile" => %{"professional_intro" => prof_intro}}, user, work_profile) do
    with {:ok, work_profile} <- Eworks.update_work_profile_prof_intro(user, work_profile, prof_intro) do
      conn
      # update the status
      |> put_status(:ok)
      # render the work profile
      |> render("work_profile.json", work_profile: work_profile, user: user)
    end # end of with
  end # end of the update the workprofile cover letter

  @doc """
    Requests a new activation key
  """
  def new_activation_key_request(conn, _params, user) do
    with :ok <- Eworks.send_new_activation_key(user) do
      conn
      # send the response
      |> put_status(:ok)
      # render success
      |> render("success.json", message: "New Activation code successfully sent to #{user.auth_email}.")
    end # end of send new activation request
  end # end of new activation key request

  @doc """
    Updates the profile picture of the current user
  """
  def update_user_profile_picture(conn, %{"profile_pic" => profile_picture_params}, user) do
    # update the profile picture
    with {:ok, user} <- Eworks.update_user_profile_picture(user, profile_picture_params) do
      conn
      # set the status to ok
      |> put_status(:ok)
      # render the user_profile
      |> render("profile.json", user: user)
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
end
