defmodule EworksWeb.SessionController do
  @moduledoc """
    Handles user login and logout functionalities
  """
  use EworksWeb, :controller
  alias EworksWeb.Authentication

  action_fallback EworksWeb.FallbackController

  @doc """
    Logins in a user
  """
  def login(conn, %{"credentials" => %{"auth_email" => email, "password" => password}} = _params) do
    # authenticate the user using the password and email
    with {:ok, result} <- Authentication.login_with_email_and_pass(email, password) do
      conn
      # put thestatus
      |> put_status(:ok)
      # render the logged in user
      |> render("logged_in.json", result)

      # the login was unsuccessful
    else
      {:error, message} ->
        # return the result
        conn
        # put the status
        |> put_status(:bad_request)
        # put the view
        |> put_view(EworksWeb.ErrorView)
        # render failed
        |> render("failed.json", message: message)
    end # end of the with for loging in the user
  end # end of login functionalities

  @doc """
    Logs out a user
  """
  def logout(conn, _params) do
    Authentication.logout(conn)
    # send a response
    |> send_resp(:ok, "")
  end # end of logout/2

end # end of the module
