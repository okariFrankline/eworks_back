defmodule EworksWeb.OrderListController do
  use EworksWeb, :controller

  import Ecto.Query, warn: false
  alias Eworks.{Orders, Repo}
  alias Eworks.Orders.{Order}
  alias Eworks.Accounts.WorkProfile
  alias Eworks.Dataloader.Loader

  @doc """
    Adds the current user as the the third arguement to all controller actions
  """
  def action(conn, _) do
    # arguements
    args = [conn, conn.params, conn.assigns.current_user]
    # apply the actions
    apply(__MODULE__, action_name(conn), args)
  end # end of action


  @doc """
    Lists all orders that have not being assinged to every user
  """
  def list_unassigned_orders(conn, %{"metadata" => after_cursor}, _user) do
    # query for getting the orders
    query = from(
      order in Order,
      # ensure the order is unassigned
      where: order.is_assigned == false,
      # preload the user
      join: user in assoc(order, :user),
      # order by
      order_by: [asc: order.inserted_at, asc: order.id],
      # preload the user
      preload: [user: user]
    )
    # get the page
    page = if after_cursor do
      # get the next cursor
      next_cursor = after_cursor
      # get the page
      Repo.paginate(query, cursor: next_cursor, cursor_fields: [:inserted_at, :id], limit: 10)

    else
      # get the first page
      Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 10)
    end # end of if for checking for the metadata

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("display_orders.json", orders: page.entries, metadata: page.metadata)
  end # end of list_unassigned_orders/3

  @doc """
    Searches for an order based on the category
  """
  def find_orders(conn, %{"category" => category, "metadata" => after_cursor}, _user) do
    # query
    query = from(
      order in Order,
      # ensure ht ecategory of the order is similar
      where: order.is_assigned == false and order.is_cancelled == false and ilike(order.category, ^category),
      # join the owner
      join: user in assoc(order, :user),
      # order by the inserted at
      order_by: [asc: order.inserted_at, asc: order.id],
      # preload the user
      preload: [user: user]
    )

    # get the page
    page = if after_cursor do
      # get the next cursor
      next_cursor = after_cursor
      # get the page
      Repo.paginate(query, cursor: next_cursor, cursor_fields: [:inserted_at, :id], limit: 10)

    else
      # get the first page
      Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 10)
    end # end of if for checking for the metadata

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("display_orders.json", orders: page.entries, metadata: page.metadata)
  end # end of find_orders.3

  @doc """
    Lists the orders made by the current user
  """
  def list_current_user_created_orders(conn, %{"metadata" => after_cursor}, user) do
    # query for getting the orders created by hte current user
    query = from(
      order in Order,
      # ensure user id matches the id of the current user
      where: order.user_id == ^user.id and order.is_paid_for == false,
      # join the order_offers
      join: offer in assoc(order, :order_offers),
      # only preload offers that have not been cancelled
      where: offer.is_cancelled == false and offer.is_rejected == false,
      # order by inserted at
      order_by: [desc: order.inserted_at],
      # preload the order
      preload: [order_offers: offer]
    )

    # get the page
    page = if after_cursor do
      # get the next cursor
      next_cursor = after_cursor
      # get the page
      Repo.paginate(query, cursor: next_cursor, cursor_fields: [:inserted_at], limit: 10)
    else
      # get the first page
      Repo.paginate(query, cursor_fields: [:inserted_at], limit: 10)
    end # end of if for checking for the metadata

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("created_orders.json", orders: page.entries, metadata: page.metadata)
  end # end of getting the orders created by the current users.

  @doc """
    Lists the contracts that have being assigned to the current user
  """
  def list_orders_assigned_to_current_user(conn, _params, user) do
    # preload the work profile of the current user
    %WorkProfile{assigned_orders: order_ids} = _work_profile = Repo.preload(user, [:work_profile]).work_profile

    # check if the assigned orders is empty
     assigned_orders = if not Enum.empty?(order_ids) do
      # get the loader
      Loader.get_data_loader()
      # load the orders with the given ids
      |> Dataloader.load_many(Orders, Order, order_ids)
      # run the loader
      |> Dataloader.run()
      # get the orders
      |> Dataloader.get_many(Ordes, Order, order_ids)
    else
      # return an empty list
      []
    end # end of assigned orders

    # return the resuls
    conn
    # put the status
    |> put_status(:ok)
    # render the order
    |> render("assigned_orders.json", orders: assigned_orders)
  end # end of list_order_assigned_to_current_user/3

  @doc """
    Gets an order specified by a given id that belongs to the current user
  """
  def get_order(conn, %{"order_id" => id}, _user) do
    # query for gettingt the order
    query = from(
      order in Order,
      # enssure user id is similar
      where: order.user_id == ^id,
      # join the order_offers
      join: offer in assoc(order, :order_offers),
      # only preload offers that have not been cancelled
      where: offer.is_cancelled == false and offer.is_rejected == false,
      # join the users of the offers
      join: offer_owner in assoc(offer, :user),
      # preload the order_offer
      preload: [order_offers: {offer, user: offer_owner}]
    )

    # get the result
    case Repo.one(query) do
      # the user not found
      nil ->
        # return the result
        conn
        # put the status
        |> put_status(:not_found)
        # put the view
        |> put_view(EworksWeb.ErrorView)
        # return the result
        |> render("order_not_found.json")

      # order found
      %Order{} = order ->
        conn
        # put the status
        |> put_status(:ok)
        # render the worker
        |> render("my_order.json", order: order)
    end # end of case for getting worker
  end # end of get order

  @doc """
    Gets an order that has been assigned to the current user
  """
  def get_assigned_order(conn, %{"order_id" => id}, _user) do
    order = Orders.get_order!(id)
    # return the result
    conn
    # put the status
    |> put_status(:ok)
    # render the worker
    |> render("my_assigned_order.json", order: order)

  rescue
    Ecto.NoResultsError ->
      # return the result
      conn
      # put the status
      |> put_status(:not_found)
      # put the view
      |> put_view(EworksWeb.ErrorView)
      # return the result
      |> render("order_not_found.json")
  end # end of get_assigned_order

end # end of module
