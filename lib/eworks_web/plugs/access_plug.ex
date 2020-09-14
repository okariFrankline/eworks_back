defmodule EworksWeb.Plugs.AccessPlug do
  @moduledoc """
  Defines a plug that ensures any useer does not access account without being logged in
  """
  @behaviour Plug

  import Plug.Conn

  # init function
  def init(options), do: options

  # call function
  def call(conn, _opts) do
    # get the current user from the connection
    current_user = Map.get(conn.assigns, :current_user)

    # ensure that the user is not nil
    if current_user !== nil do
      # return the conn
      conn
    else
      # the current user is nil
      conn
      # send a response of not not authorized
      |> send_resp(401, "Failed. Please log in to continue.")
      # halt the continuation of the conn processing
      |> halt()
    end # end of the current user
  end # end of call function

end # end of the module
