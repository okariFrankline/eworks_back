defmodule EworksWeb.OrderListView do
  use EworksWeb, :view
  alias Eworks.API.Utils
  alias Eworks.Uploaders.OrderAttachment
  alias EworksWeb.OrderView

  @doc """
    Renders the display_orders.json
  """
  def render("display_orders.json", %{orders: orders, metadata: metadata}) do
    %{
      data: %{
        orders: render_many(orders, __MODULE__, "order.json"),
        cursor_after: metadata.after
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
    Renders assigned_orders.json
  """
  def render("assigned_orders.json", %{orders: orders, un_paid: unpaid, paid: paid, in_progress: in_progress}) do
    IO.inspect(orders)
    %{
      data: %{
        orders: render_many(orders, __MODULE__, "created_order.json"),
        un_paid_count: unpaid,
        paid_count: paid,
        in_progress_count: in_progress
      }
    }
  end # end of assigned_orders.json

  @doc """
    Renders my_order.json
  """
  def render("my_order.json", %{order: order}) do
    render_one(order, OrderView, "order.json")
  end # end of my_order.json

  # def render("my_assigned_order.json", %{order: order}) do
  #   %{
  #     data: %{
  #       order: render_one(order, __MODULE__, "assigned_order.json")
  #     }
  #   }
  # end # end of my_assigned_order.json

  @doc """
    Renders the assigned_order.json
  """
  def render("assigned_order.json", %{order: order}) do
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
      owner_name: order.owner_name
    }
  end # end of assigned_order.json

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
      owner_name: order.owner_name
    }
  end # end of order.json

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

end # end of module
