defmodule EworksWeb.OrderOfferController do
  use EworksWeb, :controller

  alias Eworks.Orders
  alias Eworks.Orders.OrderOffer

  action_fallback EworksWeb.FallbackController

  def index(conn, _params) do
    order_offers = Orders.list_order_offers()
    render(conn, "index.json", order_offers: order_offers)
  end

  def create(conn, %{"order_offer" => order_offer_params}) do
    with {:ok, %OrderOffer{} = order_offer} <- Orders.create_order_offer(order_offer_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.order_offer_path(conn, :show, order_offer))
      |> render("show.json", order_offer: order_offer)
    end
  end

  def show(conn, %{"id" => id}) do
    order_offer = Orders.get_order_offer!(id)
    render(conn, "show.json", order_offer: order_offer)
  end

  def update(conn, %{"id" => id, "order_offer" => order_offer_params}) do
    order_offer = Orders.get_order_offer!(id)

    with {:ok, %OrderOffer{} = order_offer} <- Orders.update_order_offer(order_offer, order_offer_params) do
      render(conn, "show.json", order_offer: order_offer)
    end
  end

  def delete(conn, %{"id" => id}) do
    order_offer = Orders.get_order_offer!(id)

    with {:ok, %OrderOffer{}} <- Orders.delete_order_offer(order_offer) do
      send_resp(conn, :no_content, "")
    end
  end
end
