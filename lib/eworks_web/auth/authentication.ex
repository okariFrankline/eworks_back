defmodule EworksWeb.Authentication do
  @moduledoc """
    Provides functions for authenticating a user
  """
  alias Eworks.{Accounts, Repo}
  alias Eworks.Accounts.{User, Session}
  alias __MODULE__.Guardian

  @doc """
  Authentcates a user given the email address and the password
  """
  def verify_with_pass_and_email(email, password) when is_binary(email) and is_binary(password) do
    # get the user with the given email address
    case Accounts.get_user_by_email(email) do
      # user not found
      nil ->
        # return error user not found
        {:error, "Failed. User with email address: #{email} does not exist."}

      # user found
      %User{} = user ->
        # verify the user's password
        case Argon2.check_pass(user, password) do
          {:ok, %User{} = _user} = result ->
            # return the resutl
            result

          {:error, _message} ->
            # return an error message
            {:error, "Failed. The credentials provided are invalid."}
        end # end of veriifying the user password
    end # end of case for getting a user b a given email address
  end # end of verifying that the user provided password and email

  @doc """
    Creates a jwt token and stores it in the database once the user has being authenticated
  """
  # function for returning a token
  def create_token(user) do
    # create a session for the iser
    # encode and sign the user and create a new session for the user
    with {:ok, jwt, _claims} <- Guardian.encode_and_sign(user), %Session{} = _session <- Accounts.store_session(user, jwt) do
        # return the token
        {:ok, jwt}
    end # end of with for encoding and signing the token
  end # end of create token

  @doc """
  Login a user with theire username and email address
  """
  def login_with_email_and_pass(email, password) do
    with {:ok, user} <- verify_with_pass_and_email(email, password), {:ok, jwt} <- create_token(user) do
      # return result
      {:ok, %{user: user, token: jwt}}
    end # end of with
  end # end of login_with_email_and pass

  @doc """
    Logouts the user
  """
  def logout(%{assigns: %{current_session: session}} = conn) do
    # delete the current token
    with _session <- Repo.delete!(session) do
      # log out the user from guardian
      conn
      # sign out user
      |> Guardian.Plug.sign_out()
    end # end of with for deleting the session


  end # end of log out
end # end of the authentication module
