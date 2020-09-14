defmodule EworksWeb.UserController do
  use EworksWeb, :controller

  alias Eworks
  alias Eworks.Accounts
  alias Eworks.Accounts.User
  alias Eworks.Utils.{Mailer, NewEmail}
  alias EworksWeb.Authentication
  alias Eworks.Plugs

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
    # create a new user and store a token for them
    with {:ok, %User{} = user} <- Eworks.register_user(user_params), {:ok, jwt} <- Authentication.create_token(user) do
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
      |> render("activated.json", user: user)
    end # end of with for verifying account
  end # end of the activate_account/2

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
