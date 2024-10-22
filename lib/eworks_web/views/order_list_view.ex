defmodule EworksWeb.OrderListView do
  use EworksWeb, :view
  alias Eworks.API.Utils
  alias Eworks.Uploaders.OrderAttachment
  alias EworksWeb.Orders.OrderView

  @doc """
    Renders the display_orders.json
  """
  def render("display_orders.json", %{orders: orders, next_cursor: cursor}) do
    %{
      data: %{
        orders: render_many(orders, __MODULE__, "order.json"),
        next_cursor: cursor
      }
    }
  end # end of display_orders.json

  @doc """
    renders created_orders.json
  """
  def render("created_orders.json", %{orders: orders, next_cursor: cursor}) do
    %{
      data: %{
        orders: render_many(orders, __MODULE__, "created_order.json"),
        next_cursor: cursor
      }
    }
  end # end of created_orders.json

  @doc """
    renders created_orders.json
  """
  def render("direct_hire_orders.json", %{orders: orders, next_cursor: cursor}) do
    %{
      data: %{
        orders: render_many(orders, __MODULE__, "hire_order.json"),
        next_cursor: cursor
      }
    }
  end # end of created_orders.json

  @doc """
    Renders assigned_orders.json
  """
  def render("assigned_orders.json", %{orders: orders}) do
    orders = Enum.filter(orders, fn order -> not is_nil(order) end)
    %{
      data: %{
        orders: render_many(orders, __MODULE__, "assigned_order.json"),
      }
    }
  end # end of assigned_orders.json

  # def render("my_assigned_orders.json", %{orders: orders}) do
  #   orders = Enum.filter(orders, fn order -> not is_nil(order) end)
  #   %{
  #     data: %{
  #       orders: render_many(orders, __MODULE__, "assigned_order.json")
  #     }
  #   }
  # end

  @doc """
    Renders my_order.json
  """
  def render("my_order.json", %{order: order}) do
    render_one(order, OrderView, "order.json")
  end # end of my_order.json


  @doc """
    Renders the assigned_order.json
  """
  def render("assigned_order.json", %{order_list: order}) do
    %{
      id: order.id,
      description: order.description,
      is_verified: order.is_verified,
      is_assigned: order.is_assigned,
      is_complete: order.is_complete,
      is_paid_for: order.is_paid_for,
      is_cancelled: order.is_cancelled,
      specialty: order.specialty,
      category: order.category,
      duration: order.duration,
      order_type: order.order_type,
      payment_schedule: order.payment_schedule,
      payable_amount: order.payable_amount,
      show_more: order.show_more,
      posted_on: NaiveDateTime.to_iso8601(order.inserted_at),
      attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order})),
      owner_name: order.owner_name,
      offers: render_offers(order.order_offers)
    }
  end # end of assigned_order.json

  @doc """
   Renders offer.json
  """
  def render("offer.json", %{order_list: offer}) do
    %{
      id: offer.id,
      asking_amount: offer.asking_amount
    }
  end # end of render offer

  @doc """
    Renders the created_order.json
  """
  def render("created_order.json", %{order_list: order}) do
    %{
      id: order.id,
      description: order.description,
      is_verified: order.is_verified,
      is_assigned: order.is_assigned,
      is_complete: order.is_complete,
      is_paid_for: order.is_paid_for,
      accepted_offers: order.accepted_offers,
      specialty: order.specialty,
      category: order.category,
      active_offers: active_offers(order.order_offers),
      duration: order.duration,
      order_type: order.order_type,
      show_more: order.show_more,
      payment_schedule: order.payment_schedule,
      payable_amount: order.payable_amount,
      deadline: show_deadline(order.deadline),
      required_contractors: order.required_contractors,
      owner_name: order.owner_name,
      posted_on: NaiveDateTime.to_iso8601(order.inserted_at),
      attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order})),
      request: render_request(order.direct_hire)
    }
  end # end of created_order.json

  @doc """
    Renders the created_order.json
  """
  def render("hire_order.json", %{order_list: order}) do
    %{
      id: order.id,
      description: order.description,
      is_verified: order.is_verified,
      is_assigned: order.is_assigned,
      is_complete: order.is_complete,
      is_paid_for: order.is_paid_for,
      accepted_offers: order.accepted_offers,
      specialty: order.specialty,
      category: order.category,
      duration: order.duration,
      order_type: order.order_type,
      show_more: order.show_more,
      payment_schedule: order.payment_schedule,
      payable_amount: order.payable_amount,
      deadline: show_deadline(order.deadline),
      required_contractors: order.required_contractors,
      owner_name: order.owner_name,
      posted_on: NaiveDateTime.to_iso8601(order.inserted_at),
      attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order}))
    }
  end # end of created_order.json

  @doc """
    Renders order.json
  """
  def render("order.json", %{order_list: order}) do
    %{
      # order info
      id: order.id,
      order_type: order.order_type,
      description: order.description,
      is_verified: order.is_verified,
      specialty: order.specialty,
      category: order.category,
      attachments: Utils.upload_url(OrderAttachment.url({order.attachments, order})),
      duration: order.duration,
      # payment info
      payment_schedule: order.payment_schedule,
      payable_amount: order.payable_amount,
      deadline: show_deadline(order.deadline),
      required_contractors: order.required_contractors,
      posted_on: NaiveDateTime.to_iso8601(order.inserted_at),
      show_more: order.show_more,
      owner_name: order.owner_name,
      offer_owners: show_offer_owners(order.order_offers)
    }
  end # end of order.json


  @doc """
    Render request.json
  """
  def render("request.json", %{order_list: request}) do
    %{
      id: request.id
    }
  end

  defp show_deadline(date) when is_nil(date), do: nil
  defp show_deadline(date), do: Date.to_iso8601(date)

  # function for active offers
  defp active_offers(offers) when offers == [], do: 0
  defp active_offers(offers) do
    # return only the offers that are active
    offers
    # map only the active offers
    |> Enum.filter(fn offer ->
      # ensure the offer is not cancelled or rejected
      if not offer.is_rejected and not offer.is_cancelled, do: offer
    end)
    # retunr the number
    |> Enum.count()
  end

  # function for rendering the request
  defp render_request(request) when is_nil(request), do: nil
  defp render_request(request), do: render_one(request, __MODULE__, "request.json")

  # function for rendering offers
  defp render_offers(offers) when is_list(offers), do: render_many(offers, __MODULE__, "offer.json")
  defp render_offers(_offers), do: []

  # function for showing offer owners
  defp show_offer_owners(offers) when offers == [], do: []
  defp show_offer_owners(offers) do
    # for each of the offers return the user-id
    Enum.map(offers, fn offer -> offer.user_id end)
  end # end of show offer owners

end # end of module
