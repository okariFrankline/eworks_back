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
    |> put_view(EworksWeb.ErrorView)
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
    |> put_view(EworksWeb.ErrorView)
    # render the same_email json
    |> render("same_email.json", message)
  end # end of handling he similar email error

  # function for handling an error where the user is not a client and trying to submit an offer
  # def call(conn, {:error, :is_client}) do
  #   conn
  #   |> put_status(:unauthorized)
  #   # put_view
  #   |> put_view(EworksWeb.ErrorView)
  #   # render the is client
  #   |> render("is_client.json")
  # end # end of function

  def call(conn, {:error, :is_client}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(EworksWeb.ErrorView)
    |> render("is_client.json")
  end # end of is client

  # function for handling an error where a given order has already being assigned
  def call(conn, {:error, :already_assigned}) do
    conn
    # put the status
    |> put_status(:bad_request)
    # rput a view
    |> put_view(EworksWeb.ErrorView)
    # render the already assigned
    |> render("already_assigned.json")
  end

  # function for handling an error where a given offer has already being cancelled
  def call(conn, {:error, :offer_cancelled}) do
    conn
    # put the status
    |> put_status(:bad_request)
    # rput a view
    |> put_view(EworksWeb.ErrorView)
    # render the already assigned
    |> render("cancelled_offer.json")
  end

  # invalid activation key error
  def call(conn, {:error, :invalid_activation_key}) do
    conn
    |> put_status(:bad_request)
    |> put_view(EworksWeb.ErrorView)
    |> render("invalid_activation_key.json")
  end

   # invalid activation key error
   def call(conn, {:error, :invalid_verification_code}) do
    conn
    |> put_status(:bad_request)
    |> put_view(EworksWeb.ErrorView)
    |> render("invalid_verification_code.json")
  end

  # user_is_suspended
  def call(conn, {:error, :user_suspended, user_name}) do
    conn
    # put_status
    |> put_status(:bad_request)
    # put the error view
    |> put_view(EworksWeb.ErrorView)
    # render the user_is_suspended
    |> render("user_suspended.json", user_name: user_name)
  end

  # professional not found
  def call(conn, {:error, :prof_not_found}) do
    conn
    # put the view
    |> put_status(:not_found)
    # put view
    |> put_view(EworksWeb.ErrorView)
    # render the professional not found
    |> render("prof_not_found.json")
  end # end of professional found

  def call(conn, {:error, :max_offers_reached}) do
    conn
    |> put_status(:bad_request)
    |> put_view(EworksWeb.ErrorView)
    |> render("max_offers.json")
  end

end
