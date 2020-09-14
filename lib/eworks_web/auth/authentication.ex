defmodule EworksWeb.Authentication do
  @moduledoc """
    Provides functions for authenticating a user
  """
  alias Eworks.Accounts
  alias Eworks.Accounts.User
  alias __MODULE__.Guardian

  @doc """
        authenitcate returns {:ok, %User{}} if the user if found and the credentials are correct
        Retruns {:error, "invalid password"} if the user is found and the credentials are wrong
        Returns {:error, "invalid user-identifier"} if the user is not found in the db
    """
    @spec authenticate(user :: Accounts.User, password :: String.t) :: {:ok, Accounts.User} | {:error, String.t} | {:error, String.t}
    def verify_password(user, password), do: user |> Argon2.check_pass(password)

  @doc """
  Authentcates a user given the email address and the password
  """
  def verify_with_pass_and_email(email, password) when is_binary(email) and is_binary(password) do
    # get the user with the given email address
    case Accounts.get_user_by_email(email) do
      # user not found
      nil ->
        # return error user not found
        {:error, "User with email address: #{email} does not exist."}

      # user found
      %User = user ->
        # verify the user's password
        case verify_password(user, password) do
          {:ok, _user} = result ->
            # return the resutl
            result

          {:error, _message} ->
            # return an error message
            {:error, "Failed. Invalid user credentials"}
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
    with {:ok, jwt, _claims} <- Guardian.encode_and_sign(user), {:ok, _} <- Accounts.create_session(user, jwt) do
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
  end
end # end of the authentication module
