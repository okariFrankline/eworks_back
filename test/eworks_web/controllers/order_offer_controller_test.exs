defmodule EworksWeb.OrderOfferControllerTest do
  use EworksWeb.ConnCase

  alias Eworks.Orders
  alias Eworks.Orders.OrderOffer

  @create_attrs %{
    asking_mount: "some asking_mount",
    is_accepted: true,
    is_pending: true,
    is_rejected: true
  }
  @update_attrs %{
    asking_mount: "some updated asking_mount",
    is_accepted: false,
    is_pending: false,
    is_rejected: false
  }
  @invalid_attrs %{asking_mount: nil, is_accepted: nil, is_pending: nil, is_rejected: nil}

  def fixture(:order_offer) do
    {:ok, order_offer} = Orders.create_order_offer(@create_attrs)
    order_offer
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all order_offers", %{conn: conn} do
      conn = get(conn, Routes.order_offer_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order_offer" do
    test "renders order_offer when data is valid", %{conn: conn} do
      conn = post(conn, Routes.order_offer_path(conn, :create), order_offer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.order_offer_path(conn, :show, id))

      assert %{
               "id" => id,
               "asking_mount" => "some asking_mount",
               "is_accepted" => true,
               "is_pending" => true,
               "is_rejected" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.order_offer_path(conn, :create), order_offer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order_offer" do
    setup [:create_order_offer]

    test "renders order_offer when data is valid", %{conn: conn, order_offer: %OrderOffer{id: id} = order_offer} do
      conn = put(conn, Routes.order_offer_path(conn, :update, order_offer), order_offer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.order_offer_path(conn, :show, id))

      assert %{
               "id" => id,
               "asking_mount" => "some updated asking_mount",
               "is_accepted" => false,
               "is_pending" => false,
               "is_rejected" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, order_offer: order_offer} do
      conn = put(conn, Routes.order_offer_path(conn, :update, order_offer), order_offer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order_offer" do
    setup [:create_order_offer]

    test "deletes chosen order_offer", %{conn: conn, order_offer: order_offer} do
      conn = delete(conn, Routes.order_offer_path(conn, :delete, order_offer))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.order_offer_path(conn, :show, order_offer))
      end
    end
  end

  defp create_order_offer(_) do
    order_offer = fixture(:order_offer)
    %{order_offer: order_offer}
  end
end
