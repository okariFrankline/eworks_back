defmodule EworksWeb.OrderControllerTest do
  use EworksWeb.ConnCase

  alias Eworks.Orders
  alias Eworks.Orders.Order

  @create_attrs %{
    attachments: [],
    category: "some category",
    deadline: ~D[2010-04-17],
    description: "some description",
    duration: "some duration",
    is_assigned: true,
    is_complete: true,
    is_paid_for: true,
    is_verified: true,
    max_payment: "some max_payment",
    min_payment: "some min_payment",
    required_contractors: 42,
    specialty: "some specialty",
    title: "some title"
  }
  @update_attrs %{
    attachments: [],
    category: "some updated category",
    deadline: ~D[2011-05-18],
    description: "some updated description",
    duration: "some updated duration",
    is_assigned: false,
    is_complete: false,
    is_paid_for: false,
    is_verified: false,
    max_payment: "some updated max_payment",
    min_payment: "some updated min_payment",
    required_contractors: 43,
    specialty: "some updated specialty",
    title: "some updated title"
  }
  @invalid_attrs %{attachments: nil, category: nil, deadline: nil, description: nil, duration: nil, is_assigned: nil, is_complete: nil, is_paid_for: nil, is_verified: nil, max_payment: nil, min_payment: nil, required_contractors: nil, specialty: nil, title: nil}

  def fixture(:order) do
    {:ok, order} = Orders.create_order(@create_attrs)
    order
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all orders", %{conn: conn} do
      conn = get(conn, Routes.order_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order" do
    test "renders order when data is valid", %{conn: conn} do
      conn = post(conn, Routes.order_path(conn, :create), order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.order_path(conn, :show, id))

      assert %{
               "id" => id,
               "attachments" => [],
               "category" => "some category",
               "deadline" => "2010-04-17",
               "description" => "some description",
               "duration" => "some duration",
               "is_assigned" => true,
               "is_complete" => true,
               "is_paid_for" => true,
               "is_verified" => true,
               "max_payment" => "some max_payment",
               "min_payment" => "some min_payment",
               "required_contractors" => 42,
               "specialty" => "some specialty",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.order_path(conn, :create), order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order" do
    setup [:create_order]

    test "renders order when data is valid", %{conn: conn, order: %Order{id: id} = order} do
      conn = put(conn, Routes.order_path(conn, :update, order), order: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.order_path(conn, :show, id))

      assert %{
               "id" => id,
               "attachments" => [],
               "category" => "some updated category",
               "deadline" => "2011-05-18",
               "description" => "some updated description",
               "duration" => "some updated duration",
               "is_assigned" => false,
               "is_complete" => false,
               "is_paid_for" => false,
               "is_verified" => false,
               "max_payment" => "some updated max_payment",
               "min_payment" => "some updated min_payment",
               "required_contractors" => 43,
               "specialty" => "some updated specialty",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      conn = put(conn, Routes.order_path(conn, :update, order), order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order" do
    setup [:create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      conn = delete(conn, Routes.order_path(conn, :delete, order))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.order_path(conn, :show, order))
      end
    end
  end

  defp create_order(_) do
    order = fixture(:order)
    %{order: order}
  end
end
