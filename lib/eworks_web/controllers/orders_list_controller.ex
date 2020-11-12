defmodule EworksWeb.OrderListController do
  use EworksWeb, :controller

  import Ecto.Query, warn: false
  alias Eworks.{Orders, Repo}
  alias Eworks.Orders.{Order}

  action_fallback EworksWeb.FallbackController

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
  def list_unassigned_orders(conn, %{"next_cursor" => cursor}, user) do
    # query for getting the orders
    query = from(
      order in Order,
      # ensure the order is unassigned and they do not belong to current user
      where: order.is_assigned == false and order.is_cancelled == false and order.user_id != ^user.id,
      # preload the user
      join: user in assoc(order, :user),
      # order by
      order_by: [asc: order.inserted_at, asc: order.id],
      # preload the user
      preload: [user: user]
    )
    # get the page
    page = if cursor == "false" do
      # get the page
      Repo.paginate(query, cursor_fields: [:inserted_at, :id], limit: 5)
    else
      # get the first page
      Repo.paginate(query, after: cursor, cursor_fields: [:inserted_at, :id], limit: 5)
    end # end of if for checking for the metadata

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("display_orders.json", orders: page.entries, next_cursor: page.metadata.after)
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
  def list_current_user_created_orders(conn, %{"next_cursor" => after_cursor, "filter" => filter}, user) do
    # query for getting the orders created by hte current user
    query = from(
      order in Order,
      # ensure user id matches the id of the current user
      where: order.user_id == ^user.id and order.is_cancelled == false,
      # join the direct hire
      left_join: hire in assoc(order, :direct_hire),
      # join the order_offers
      left_join: offer in assoc(order, :order_offers),
      # ensure the offer is rejected and the offer is not cancelled
      on: offer.is_rejected == false and offer.is_cancelled == false,
      # order by inserted at
      order_by: [desc: order.inserted_at],
      # proload the offers
      preload: [order_offers: offer, direct_hire: hire]
    )

    # modify query depending on the filter
    query = case filter do
      "unassigned" ->
        from(order in query, where: order.is_assigned == false)

      "in_progress" ->
        from(order in query, where: order.is_assigned == true and order.is_complete == false)

      "complete" ->
        from(order in query, where: order.is_complete == true and order.is_paid_for == false)

    end

    # get the page
    page = if after_cursor != "false" do
      # get the page
      Repo.paginate(query, cursor: after_cursor, cursor_fields: [:inserted_at], limit: 10)
    else
      # get the first page
      Repo.paginate(query, cursor_fields: [:inserted_at], limit: 10)
    end # end of if for checking for the metadata

    IO.inspect(Enum.count(page.entries))

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("created_orders.json", orders: page.entries, next_cursor: page.metadata.after)
  end # end of getting the orders created by the current users.

  @doc """
    Lists the orders made by the current user
  """
  def list_orders_for_direct_hire(conn, %{"next_cursor" => after_cursor}, user) do
    # query for getting the orders created by hte current user
    query = from(
      order in Order,
      # ensure user id matches the id of the current user
      where: order.user_id == ^user.id and order.is_cancelled == false and  order.is_assigned == false,
      # join the direct hires
      left_join: hire in assoc(order, :direct_hire),
      # order by inserted at
      order_by: [desc: order.inserted_at],
      # proload the offers
      preload: [direct_hire: hire]
    )

    # get the page
    page = if after_cursor != "false" do
      # get the page
      Repo.paginate(query, cursor: after_cursor, cursor_fields: [:inserted_at], limit: 10)
    else
      # get the first page
      Repo.paginate(query, cursor_fields: [:inserted_at], limit: 10)
    end # end of if for checking for the metadata

    # return the orders that do not already have a direct hire request
    orders = Enum.filter(page.entries, fn order -> is_nil(order.direct_hire) end)

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("direct_hire_orders.json", orders: orders, next_cursor: page.metadata.after)
  end # end of getting the orders created by the current users.

  @doc """
    Lists the contracts that have being assigned to the current user
  """
  def list_orders_assigned_to_current_user(conn, %{"filter" => filter}, user) do
    if user.user_type == "Independent Contractor" or user.is_upgraded_contractor do
      # preload the work profile of the current user
      work_profile = Repo.preload(user, [:work_profile]).work_profile

      # check if the assigned orders is empty
      orders = if not Enum.empty?(work_profile.assigned_orders) do
        Dataloader.new
        # add the source
        |> Dataloader.add_source(Orders, Orders.data())
        # load the orders
        |> Dataloader.load_many(Orders, {Orders.Order, filter: filter, user_id: user.id}, work_profile.assigned_orders)
        # run the dataloader
        |> Dataloader.run()
        # get the results
        |> Dataloader.get_many(Orders, {Orders.Order, filter: filter, user_id: user.id}, work_profile.assigned_orders)

      else # the ids are empty
        # return an empty list
        []
      end

      # return the resuls
      conn
      # put the status
      |> put_status(:ok)
      # render the order
      |> render("assigned_orders.json", orders: orders, in_progress: work_profile.in_progress, un_paid: work_profile.un_paid, paid: work_profile.recently_paid)

    else
      # the user is a client
      conn
      # put status
      |> put_status(:forbidden)
      # put view
      |> put_view(EworksWeb.ErrorView)
      # render is client
      |> render("is_client.json", message: "Complete a One Time Upgrade and get assigned orders then try again.")
    end
  end # end of list_order_assigned_to_current_user/3

  @doc """
    Gets an order specified by a given id that belongs to the current user
  """
  def get_order(conn, %{"order_id" => id}, _user) do
    # get the order
    order = Orders.get_order!(id)

    conn
    # put the status
    |> put_status(:ok)
    # render the worker
    |> render("my_order.json", order: order)

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
