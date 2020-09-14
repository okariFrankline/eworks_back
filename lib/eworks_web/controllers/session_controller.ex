defmodule EworksWeb.SessionController do
  @moduledoc """
    Handles user login and logout functionalities
  """
  use EworksWeb, :controller
  alias EworksWeb.Authentication

  @doc """
    Logins in a user
  """
  def login(conn, %{"credentials" => %{"email" => email, "password" => password}} = _params) do
    # authenticate the user using the password and email
    with {:ok, result} <- Authentication.login_with_email_and_password(email, password) do
      conn
      # put thestatus
      |> put_status(:ok)
      # render the logged in user
      |> render("logged_in.json", result)
    end # end of the with for loging in the user
  end # end of login functionalities

  @doc """
    Logs out a user
  """
  def logout(conn, _params) do
    conn
  end # end of logout/2

end # end of the module
