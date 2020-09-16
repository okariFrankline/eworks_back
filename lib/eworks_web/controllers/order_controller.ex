defmodule EworksWeb.OrderController do
  use EworksWeb, :controller

  alias Eworks.Orders
  alias Eworks.Orders.Order

  action_fallback EworksWeb.FallbackController

  def index(conn, _params) do
    orders = Orders.list_orders()
    render(conn, "index.json", orders: orders)
  end


  @doc """
    Creates a new order
    Order params includes: order category, order specialty
  """
  def create(%{assigns: %{current_user: user}} = conn, %{"order" => order_params}) do
    with {:ok, order} <- Eworks.create_new_order(user, order_params) do
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

  def update_order_payment(%{assigns: %{current_user: user}} = conn, %{"new_order" => %{"order_payment_params" => payment_params}, "order_id" => id}) do
    with {:ok, order} <- Eworks.update_order_payment(user, id, payment_params) do
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

  def update_order_duration(%{assigns: %{current_user: user}} = conn, %{"new_order" => %{"order_duration" => duration_params}, "order_id" => id}) do
    with {:ok, order} <- Eworks.update_order_duration(user, id, duration_params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the new order
      |> render("new_order", new_order: order)
    end # end of with for adding the order type params
  end # end of updating the order type

  @doc """
    Adds the order_type and required contractors
  """

  def update_order_duration(%{assigns: %{current_user: user}} = conn, %{"new_order" => %{"order_type" => type_params}, "order_id" => id}) do
    with {:ok, order} <- Eworks.update_order_type_and_contractors(user, id, type_params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the new order
      |> render("new_order", new_order: order)
    end # end of with for adding the order type params
  end # end of updating the order type

  @doc """
    Adds the order description
  """
  def update_order_description(%{assigns: %{current_user: user}} = conn, %{"new_order" => %{"order_description" => description}, "order_id" => id}) do
    # update the description of the order
    with {:ok, order} <- Eworks.update_order_description(user, id, description) do
      conn
      |> put_status(:ok)
      |> render("new_order.json", new_order: order)
    end # end of updating the order
  end # end of the addition of description

  @doc """
    Submits an offer for a given order
  """
  def submit_order_offer(%{assigns: %{current_user: user}} = conn, %{"new_offer" => %{"asking_amount" => asking_amount}, "order_id" => order_id}) do
    with :ok <- Eworks.submit_order_offer(user, order_id, asking_amount) do
      conn
      # put the status
      |> put_status(:created)
      # send a response to the user
      |> send_resp()
    end # end of
  end # end of submit offer

  @doc """
    Rejects an offer
  """
  def reject_order_offer(conn, %{"order_offer_id" => id}) do
    Eworks.reject_order_offer(id)
    # return a response
    conn
    # put status
    |> put_status(:ok)
    # send a response
    |> send_resp()
  end # end of reject_order_offer

  @doc """
    Accepts a given offer for a particular order
  """
  def accept_order_offer(conn, %{"order_id" => order_id, "order_offer_id" => order_offer_id}) do
    with %Order{} = order <- Eworks.accept_order_offer(user, order_offer_id, order_id) do
      conn
      # put a status
      |> put_status(:ok)
      # render the order
      |> render("order.json", order: order)
    end # end of accepting the offer
  end # end of accept_order_offer

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)

    with {:ok, %Order{}} <- Orders.delete_order(order) do
      send_resp(conn, :no_content, "")
    end
  end
end
