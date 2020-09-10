defmodule EworksWeb.OrderOfferView do
  use EworksWeb, :view
  alias EworksWeb.OrderOfferView

  def render("index.json", %{order_offers: order_offers}) do
    %{data: render_many(order_offers, OrderOfferView, "order_offer.json")}
  end

  def render("show.json", %{order_offer: order_offer}) do
    %{data: render_one(order_offer, OrderOfferView, "order_offer.json")}
  end

  def render("order_offer.json", %{order_offer: order_offer}) do
    %{id: order_offer.id,
      is_pending: order_offer.is_pending,
      is_accepted: order_offer.is_accepted,
      is_rejected: order_offer.is_rejected,
      asking_mount: order_offer.asking_mount}
  end
end
