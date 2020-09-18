defmodule EworksWeb.UserController do
  use EworksWeb, :controller

  alias Eworks
  alias Eworks.Accounts
  alias Eworks.Accounts.User
  alias Eworks.Utils.{Mailer, NewEmail}
  alias EworksWeb.Authentication


  action_fallback EworksWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  @doc """
  Creates a new account using the details given by the user
  user params must include auth_email, password, and user_account
  """
  def register(conn, %{"user" => user_params}) do
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
  def activate_account(%{assigns: %{current_user: user}} = conn, %{"activation" => %{"activation_key" => key}}) do
    # actiate the account
    with {:ok, user} <- Eworks.verify_account(user, key) do
      # return the result
      conn
      # put the okay status
      |> put_status(:ok)
      # render the loggedin.json
      |> render("profile.json", user: user)
    end # end of with for verifying account
  end # end of the activate_account/2

  @doc """
    Updates the current user's location details
  """
  def update_user_profile_location(%{assigns: %{current_user: user}} = conn, %{"user_profile" => %{"location" => location_params}}) do
    with {:ok, user} <- Eworks.update_user_profile_location(user, location_params) do
      conn
      # put an ok status
      |> put_status(:ok)
      # render the profiles view
      |> render("profile.json", user: user)
    end # end of update the profile update
  end # end of the update_user_profile_location/2

  @doc """
    Updates the email address of the current user
  """
  def update_user_profile_emails(%{assigns: %{current_user: user}} = conn, %{"user_profile" => %{"new_email" => new_email}}) do
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
  def update_user_profile_phones(%{assigns: %{current_user: user}} = conn, %{"user_profile" => %{"new_phone" => new_phone}}) do
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
  def update_work_profile_skills(%{assigns: %{current_user: user}} = conn, %{"work_profile" => %{"new_skills" => new_skills}, "work_profile_id" => id}) do
    with {:ok, work_profile} <- Eworks.update_work_profile_skills(user, id, new_skills) do
      conn
      # put ok on the status
      |> put_status(:ok)
      # render the work profile
      |> render("work_profile.json", work_profile: work_profile)
    end # end of with
  end # end of the uodate_work_profile_skills/2

  @doc """
    Updates the cover letter of a work profile
  """
  def update_work_profile_cover_letter(%{assigns: %{current_user: user}} = conn, %{"work_profile" => %{"cover_letter" => cover_letter}, "work_profile_id" => id}) do
    with {:ok, work_profile} <- Eworks.update_work_profile_cover_letter(user, id, cover_letter) do
      conn
      # update the status
      |> put_status(:ok)
      # render the work profile
      |> render("work_profile.json", work_profile: work_profile)
    end # end of with
  end # end of the update the workprofile cover letter

  @doc """
    Updates the professional introduction of a work profile
  """
  def update_work_profile_prof_intro(%{assigns: %{current_user: user}} = conn, %{"work_profile" => %{"professional_intro" => prof_intro}, "work_profile_id" => id}) do
    with {:ok, work_profile} <- Eworks.update_work_profile_prof_intro(user, id, prof_intro) do
      conn
      # update the status
      |> put_status(:ok)
      # render the work profile
      |> render("work_profile.json", work_profile: work_profile)
    end # end of with
  end # end of the update the workprofile cover letter

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
