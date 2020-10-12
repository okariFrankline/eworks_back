defmodule EworksWeb.DirectHireController do
  use EworksWeb, :controller

  alias Eworks.Requests.API

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
    with {:ok, result} <- API.create_new_direct_hire_request(user, order_id, cont_id) do
      # return the result
      conn
      # put the stauts
      |> put_status(:created)
      # render the hire
      |> render("hire.json", direct_hire: result.hire, recipient: result.recipient, order: result.order)
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
      |> render("success.json", message: "Direct Hire Request successfully rejected.")
    end # end of with
  end # end of accept direct hire request

  @doc """
    assigns an order for which a direct hire was for
  """
  def assign_order_from_direct_hire(conn, %{"direct_hire_id" => id}, user) do
    with {:ok, result} <- API.assign_order_from_direct_hire(user, id) do
      conn
      # put status
      |> put_status(:ok)
      # put view
      |> put_view(EworksWeb.OrderView)
      # render
      |> render("order.json", order: result.order, offers: result.offers)
    end # end of with
  end # end of assign_order_from_direct_hire

end
