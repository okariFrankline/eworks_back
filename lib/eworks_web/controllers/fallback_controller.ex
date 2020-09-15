defmodule EworksWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use EworksWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(EworksWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(EworksWeb.ErrorView)
    |> render(:"404")
  end

  # error when the user is not the owner of the asset they are changing
  def call(conn, {:error, :not_owner}) do
    conn
    # put status
    |> put_status(:bad_request)
    # put the error view
    |> put_view(Eworks.ErrorView)
    # render the not found page
    |> render("not_owner.json")
  end # end of call for :not_error

  # error for creating a new user
  # def call(conn, {:error, message}) do
  #   conn
  #   |> send_resp(400, message)
  # end

  # function for handling a similar email error
  def call(conn, {:error, :email_exists, message}) do
    conn
    # put status
    |> put_status(:bad_request)
    # put view
    |> put_view(Eworks.ErrorView)
    # render the same_email json
    |> render("same_email.json", message)
  end # end of handling he similar email error
end
