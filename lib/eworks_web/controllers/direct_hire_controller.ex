defmodule EworksWeb.Requests.DirectHireController do
  use EworksWeb, :controller

  alias Eworks.Requests.API
  import Ecto.Query, warn: false
  alias Eworks.Accounts.{WorkProfile}
  alias Eworks.{Repo}
  alias Eworks.Requests.DirectHire

  action_fallback EworksWeb.FallbackController

  @doc """
    set the current user
  """
  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end # end action

  @doc """
    Returns a list of requests made the current user
  """
  def list_client_direct_hires(conn, _params, user) do
    with {:ok, hires} <- API.list_direct_hires(:client, user) do
      # return the reuslt
      conn
      # put the status
      |> put_status(:ok)
      # render the hires
      |> render("contractor_hires.json", hires: hires)
    end # end of direct hires
  end # end of list my_direct hires

  @doc """
    Returns a list of all the direct hire requests made to a given contractor
  """
  def list_contractor_direct_hires(conn, _params, user) do
    with {:ok, hires} <- API.list_direct_hires(:contractor, user) do
      # return the reuslt
      conn
      # put the status
      |> put_status(:ok)
      # render the hires
      |> render("contractor_hires.json", hires: hires)
    end # end of direct hires
  end # end of list contractors direct_hires

  @doc """
    creates a new direct hire request
  """
  def create_new_direct_hire_request(conn, %{"order_id" => order_id, "contractor_id" => cont_id}, user) do
    with {:ok, hire} <- API.create_new_direct_hire_request(user, order_id, cont_id) do
      # return the result
      conn
      # put the stauts
      |> put_status(:created)
      # render the hire
      |> render("hire_success.json", message: "Success. You have successfully sent a direct hire request to the contractor.", hire_id: hire.id)
    end # end of with
  end # end of createing a new direct hire request

  @doc """
    accepts a direct hire request
  """
  def accept_direct_hire_request(conn, %{"direct_hire_id" => id}, user) do
    with {:ok, result} <- API.accept_direct_hire_request(user, id) do
      conn
      # put the stauts
      |> put_status(:ok)
      #
      |> render("hire.json", direct_hire: result.hire, recipient: result.recipient, order: result.order)
    end # end of with
  end # end of accept direct hire request

  @doc """
    rejects a direct hire request
  """
  def reject_direct_hire_request(conn, %{"direct_hire_id" => id}, user) do
    with {:ok, _hire} <- API.reject_direct_hire_request(user, id) do
      conn
      # put the stauts
      |> put_status(:ok)
      #
      |> render("success.json", message: "Success. Direct Hire Request successfully rejected.")
    end # end of with
  end # end of accept direct hire request

  @doc """
    assigns an order for which a direct hire was for
  """
  def assign_order_from_direct_hire(conn, %{"direct_hire_id" => id}, user) do
    with {:ok, _result} <- API.assign_order_from_direct_hire(user, id) do
      conn
      # put status
      |> put_status(:ok)
      # put view
      |> put_view(EworksWeb.OrderView)
      # render
      |> render("success.json", message: "Success. You have succeessfully assigned the order.")
    end # end of with
  end # end of assign_order_from_direct_hire

  @doc """
    Returns the invite
  """
  def get_direct_hire_request(conn, %{"direct_hire_id" => id}, _user) do
    # get the request
    request = from(
      request in DirectHire,
      # ensure the ids match
      where: request.id == ^id,
      # join the order
      join: order in assoc(request, :order),
      # join the work profile
      join: profile in assoc(request, :work_profile),
      # add the owner of the profile
      join: user in assoc(profile, :user),
      # preload the details
      preload: [order: order, work_profile: {profile, user: user}]
    )
    # get the request
    |> Repo.one!()

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("request.json", request: request)

  rescue
    # the request was not found
    Ecto.NoResultsError ->
      # return the result
      conn
      # put the status
      |> put_status(:not_found)
      # put the error view
      |> put_view(EworksWeb.ErrorView)
      # render failed
      |> render("failed.json", message: "Failed. The request direct hire was not found.")
  end # end of get direct hire request

  @doc """
    Cancels a direct hire
  """
  def cancel_direct_hire_request(conn, %{"direct_hire_id" => id}, user) do
    API.cancel_direct_hire_request(user, id)
    # return the result
    conn
    # put the status
    |> put_status(:ok)
    # render the result
    |> render("success.json", message: "Success. You have successfully cancelled the direct hire request.")
  end # end of cancel direct hire

end
