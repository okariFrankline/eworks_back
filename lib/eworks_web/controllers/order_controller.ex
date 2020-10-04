defmodule EworksWeb.OrderController do
  use EworksWeb, :controller

  alias Eworks.Orders.{API}
  alias EworksWeb.Plugs

  plug Plugs.OrderById when  action not in [:create_new_order, :cancel_order_offer]
  plug Plugs.CanSubmitOrderOffer when action in [:submit_order_offer]

  @doc """
    provide the current user as the thirs arguement of each action
  """
  def action(conn, _) do
    # add the current user and the order in the args of the actions
    # get the order using the Map.get/3, so that if the :order key does not exist, it returns nil
    args = [conn, conn.params, conn.assigns.current_user, Map.get(conn.assigns, :order)]
    # call the action
    apply(__MODULE__, action_name(conn), args)
  end # end of action

  @doc """
    Creates a new order
    Order params includes: order category, order specialty
  """
  def create_new_order(conn, %{"order" => order_params}, user, _order) do
    with {:ok, order} <- API.create_new_order(user, order_params) do
      conn
      # put the status
      |> put_status(:created)
      # render the new order
      |> render("new_order.json", new_order: order)
    end # end of the with
  end # end of the create order function


  @doc """
    Adds the payment information
  """

  def update_order_payment(conn, %{"new_order" => %{"order_payment" => payment_params}}, user, order) do
    with {:ok, order} <- API.update_order_payment(user, order, payment_params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the order
      |> render("new_order.json", new_order: order)
    end # end of with for adding the payment information
  end # end of the adding the payment


  @doc """
    Adds the order_type and duration
  """

  def update_order_duration(conn, %{"new_order" => %{"order_duration" => duration_params}}, user, order) do
    with {:ok, order} <- API.update_order_duration(user, order, duration_params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the new order
      |> render("new_order.json", new_order: order)
    end # end of with for adding the order type params
  end # end of updating the order type

  @doc """
    Adds the order_type and required contractors
  """

  def update_order_type_and_contractors(conn, %{"new_order" => %{"order_type" => type_params}}, user, order) do
    with {:ok, order} <- API.update_order_type_and_contractors(user, order, type_params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the new order
      |> render("new_order.json", new_order: order)
    end # end of with for adding the order type params
  end # end of updating the order type

  @doc """
    Adds the order description
  """
  def update_order_description(conn, %{"new_order" => %{"order_description" => description}}, user, order) do
    # update the description of the order
    with {:ok, order} <- API.update_order_description(user, order, description) do
      conn
      |> put_status(:ok)
      |> render("new_order.json", new_order: order)
    end # end of updating the order
  end # end of the addition of description

  @doc """
    Updates the order's attachments
  """
  def update_order_attachments(conn, %{"attachments" => attachment_params}, user, order) do
    with {:ok, order} <- API.update_order_attachments(user, order, attachment_params) do
      conn
      # put status to ok
      |> put_status(:ok)
      # render the new order
      |> render("new_order.json", new_order: order)
    end # end of with
  end # end of update_order_attachments/2

  @doc """
    Posts a new order
  """
  def send_order_verification_code(conn, _params, user, order) do
    # get the order with the given order
    with :ok <- API.send_order_verification_code(user, order) do
      conn
      # put status
      |> put_status(:ok)
      # send the response
      |> render("success.json", message: "Order verification code has been sent to the email #{user.auth_email}.")
    end
  end # end of save order and sending a verification code

  @doc """
    Verifies an order
  """
  def verify_order(conn, %{"new_order" => %{"verification_code" => verification_code}}, user, order) do
    with {:ok, order} <- API.verify_order(user, order, verification_code) do
      conn
      # put status to ok
      |> put_status(:ok)
      # render the final order
      |> render("new_order.json", new_order: order)
    end # end of verification code
  end # end of verify order

  @doc """
    Submits an offer for a given order
  """
  def submit_order_offer(conn, %{"new_offer" => %{"asking_amount" => asking_amount}}, user, order) do
    # place the offer
    {:ok, _order} = API.submit_order_offer(user, order, asking_amount)
    conn
    # put the status
    |> put_status(:created)
    # send a response to the user
    |> render("success.json", message: "Offer successfully submitted")
  end # end of submit offer


  @doc """
    Rejects an offer
  """
  def reject_order_offer(conn,  %{"order_offer_id" => id}, user, order) do
    API.reject_order_offer(user, order, id)
    # return a response
    conn
    # send a response
    |> put_status(:ok)
    # render success
    |> render("success.json", message: "Offer successfully rejected.")
  end # end of reject_order_offer

  @doc """
    Accepts a given offer for a particular order
  """
  def accept_order_offer(conn, %{"order_offer_id" => order_offer_id}, user, order) do
    with {:ok, order} <- API.accept_order_offer(user, order, order_offer_id) do
      conn
      # put a status
      |> put_status(:ok)
      # render the order
      |> render("order.json", order: order)
    end # end of accepting the offer
  end # end of accept_order_offer

  @doc """
    Assign a job to a given user
  """
  def assign_order(conn, %{"to_assign_id" => to_assign_id}, user, order) do
    with {:ok, order} <- API.assign_order(user, order, to_assign_id) do
      conn
      # ok
      |> put_status(:ok)
      # render the order
      |> render("order.json", order: order)

    else
      {:error, :already_assigned} ->
        conn
        # put the status
        |> put_status(:bad_request)
        # rput a view
        |> put_view(EworksWeb.ErrorView)
        # render the already assigned
        |> render("already_assigned.json")
    end # end of with for assigning of the order to the user
  end # end of assign order

  @doc """
    Accepts to work on a given order
  """
  def accept_order(conn, %{"order_offer_id" => offer_id}, user, order) do
    with {:ok, offer} <- API.accept_order(user, order, offer_id) do
      conn
      # put status
      |> put_status(:ok)
      # render the offer
      |> render("accepted_offer.json", accepted_offer: offer, user: user, order: order)
    end # end of the with
  end

  @doc """
    Tag order
  """
  def tag_order(conn, _params, user, order) do
    with {:ok, _order} <- API.tag_order(user, order) do
      # return the success
      conn
      # put the status
      |> put_status(:ok)
      # render the success
      |> render("success.json")
    end
  end # end of tag order

  @doc """
    Cancel order offer
  """
  def cancel_order_offer(conn, %{"order_offer_id" => id}, _user, _order) do
    API.cancel_order_offer(id)
    # return a response
    conn
    # send a response
    |> put_status(:ok)
    # render success
    |> render("success.json", message: "Offer successfully cancelled.")
  end

end # end of the module
