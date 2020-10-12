defmodule EworksWeb.Plugs.SessionPlug do
  @moduledoc """
    Places the current user in the connection
  """
  @behaviour Plug
  import Plug.Conn
  import Guardian.Plug

  # alias the user struct
  alias Eworks.Accounts.{Session}
  # imprt where
  import Ecto.Query, only: [where: 2]
  # alias Repo
  alias Eworks.Repo

  # init method
  def init(opts), do: opts

  # call function
  def call(conn, _options) do
    # get the token from guardian
    token = current_token(conn)
    # get the user with the given session
    with {:ok, result} <- authorize(token) do
      # assign the current user to the conn
      conn
      # put the current user
      |> assign(:current_user, result.user)
      # put the current session
      |> assign(:current_session, result.session)
    else
      {:error, _} ->
        # return the plug
        conn
        # put a response that indicates that the user is not logged in
        |> send_resp(401, "Failed. Please log in to register.")
        # halt the process of processing the conn
        |> halt()
    end # end of the with for autorizing the current user
  end # end of the connection

  # function for authorizing the user
  def authorize(token) do
    Session
    # filter only where the token is required
    |> where(token: ^token)
    # get one result from the dp
    |> Repo.one()
    # check if ther user exists or not
    |> case do
      # the session does not exist
      nil ->
        # return nil
        {:error, :not_authorized}
      # the user exist
      %Session{} = session ->
        # get the account
        session_with_user = session |> Repo.preload([:user])
        # return the account
        {:ok, %{session: session_with_user, user: session_with_user.user}}
    end # end of cond
  end # end of the authorize function

end# end of the module
