defmodule EworksWeb.SessionController do
  @moduledoc """
    Handles user login and logout functionalities
  """
  use EworksWeb, :controller

  @doc """
    Logins in a user
  """
  def login(conn, %{"credentials" => %{"email" => email, "password"}} = _params) do

  end # end of login functionalities

  @doc """
    Logs out a user
  """
  def logout(conn, _params) do

  end # end of logout/2

end # end of the module
