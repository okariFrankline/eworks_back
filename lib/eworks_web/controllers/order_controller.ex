defmodule EworksWeb.Orders.OrderController do
  use EworksWeb, :controller

  import Ecto.Query, warn: false
  alias Eworks.Orders.{API, OrderOffer}
  alias EworksWeb.Plugs
  alias Eworks.{Repo, Accounts, Orders}

  plug Plugs.OrderById when  action not in [:create_new_order, :cancel_order_offer]
  plug Plugs.CanSubmitOrderOffer when action in [:submit_order_offer]

  action_fallback EworksWeb.FallbackController

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
    Updates the order category
    Order params includes: order category, order specialty
  """
  def update_order_category(conn, %{"new_order" => %{"order_category" => order_params}}, user, order) do
    with {:ok, order} <- API.update_order_category(user, order,  order_params) do
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
    Posts a new order
  """
  def resend_order_verification_code(conn, _params, user, order) do
    # get the order with the given order
    with :ok <- API.resend_order_verification_code(user, order) do
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
    |> render("success.json", message: "Success. Your offer has been successfully submitted.")
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
    with {:ok, _offer} <- API.accept_order(user, order, offer_id) do
      conn
      # put status
      |> put_status(:ok)
      # render the offer
      |> render("success.json", message: "Success. Order successfully accepted.")
    end # end of the with
  end

  @doc """
    Rejects order/ to work on an offer
  """
  def reject_order(conn, %{"order_offer_id" => offer_id}, user, order) do
    with {:ok, _offer} <- API.reject_order(user, order, offer_id) do
      conn
      # put status
      |> put_status(:ok)
      # render the offer
      |> render("success.json", message: "Success. Order successfully rejected.")
    end # end of with
  end # end of reject order

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
    |> render("success.json", message: "Success. You have successfully cancelled your offer.")
  end

  @doc """
    Cancels an order
  """
  def cancel_order(conn, _params, user, order) do
    # check if the order has being assigned
    if order.is_assigned do
      # return the response
      conn
      # put the status
      |> put_status(:bad_request)
      # put error view
      |> put_view(Eworks.ErrorView)
      # render the failed
      |> render("failed.json", message: "Failed. You cannot cancel an order that is in progress.")

    else
      # cancel the order
      with {:ok, _order} <- API.cancel_order(user, order) do
        # return the result
        conn
        # pust status
        |> put_status(:ok)
        # render the success.json
        |> render("success.json", message: "Success. You have successfully cancelled the order.")
      end # end of with
    end # end of checking if the erder has being assigned
  end # end of cancelling an order

  @doc """
    marks an order complete
  """
  def mark_order_complete(conn, _params, user, order) do
    with {:ok, _profile} <- API.mark_order_complete(user, order) do
      # return a response
      conn
      # put the status
      |> put_status(:ok)
      # return the result
      |> render("success.json", message: "Success. You have successfully marked the order as complete.")
    end
  end # end of marking an order complete

  @doc """
    Gets an order specified by a given id that belongs to the current user
  """
  def get_order(conn, _params, _user, order) do
    conn
    # put the status
    |> put_status(:ok)
    # render the worker
    |> render("my_order.json", order: order)
  end # end of get order

  @doc """
    Gets the offers for a given order
  """
  def list_order_offers(conn, %{"filter" => filter, "next_cursor" => cursor}, _user, order) do
    # query for the order offers
    query = from(
      offer in OrderOffer,
      # ensure they belong to the order
      where: offer.order_id == ^order.id and offer.is_cancelled == false,
      # join the user who is the owner of the offer
      join: user in assoc(offer, :user),
      # join the work profile for the user
      join: profile in assoc(user, :work_profile),
      # order
      order_by: [asc: offer.inserted_at],
      # preload the user
      preload: [user: {user, work_profile: profile}]
    )

    # modify the query based on the filter
    query = case filter do
      "pending" ->
        from(offer in query, where: offer.is_pending == false)

      "accepted" ->
        from(offer in query, where: offer.is_accepted == true and offer.has_accepted_order == false)
    end # end of query modification

    # return the results based on the next_cursor
    page = if cursor == "false" do
      Repo.paginate(query, cursor_fields: [:inserted_at], limit: 5)
    else
      Repo.paginate(query, after: cursor, cursor_fields: [:inserted_at], limit: 5)
    end # end of if for getting the result

    IO.inspect(page.entries)

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the offers
    |> render("offers.json", offers: page.entries, next_cursor: page.metadata.after)
  end # end of list order offers

  @doc """
    Returns the assignees of a given order
  """
  def list_order_assignees(conn, _params, _user, order) do
    # get the assignees
    assignees = order.assignees
    # get the assignees
    assignees = if  not Enum.empty?(assignees) do
      # load the dataloader
      Dataloader.new()
      # add the source
      |> Dataloader.add_source(Accounts, Accounts.data())
      # load the assignees
      |> Dataloader.load_many(Accounts, Accounts.User, assignees)
      # run the dataloader
      |> Dataloader.run()
      # get the results
      |> Dataloader.get_many(Accounts, Accounts.User, assignees)
    else
      []
    end # end of assignees

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the assignees
    |> render("assignees.json", assignees: assignees)
  end # end of list_order_assignees

end # end of the module
