defmodule EworksWeb.OrderView do
  use EworksWeb, :view
  alias EworksWeb.OrderView

  def render("index.json", %{orders: orders}) do
    %{data: render_many(orders, OrderView, "order.json")}
  end

  def render("show.json", %{order: order}) do
    %{data: render_one(order, OrderView, "order.json")}
  end

  def render("order.json", %{order: order}) do
    %{id: order.id,
      description: order.description,
      is_verified: order.is_verified,
      is_assigned: order.is_assigned,
      is_complete: order.is_complete,
      is_paid_for: order.is_paid_for,
      duration: order.duration,
      deadline: order.deadline,
      category: order.category,
      min_payment: order.min_payment,
      max_payment: order.max_payment,
      required_contractors: order.required_contractors,
      title: order.title,
      specialty: order.specialty,
      attachments: order.attachments}
  end
end
