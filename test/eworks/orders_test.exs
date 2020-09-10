defmodule Eworks.OrdersTest do
  use Eworks.DataCase

  alias Eworks.Orders

  describe "orders" do
    alias Eworks.Orders.Order

    @valid_attrs %{attachments: [], category: "some category", deadline: ~D[2010-04-17], description: "some description", duration: "some duration", is_assigned: true, is_complete: true, is_paid_for: true, is_verified: true, max_payment: "some max_payment", min_payment: "some min_payment", required_contractors: 42, specialty: "some specialty", title: "some title"}
    @update_attrs %{attachments: [], category: "some updated category", deadline: ~D[2011-05-18], description: "some updated description", duration: "some updated duration", is_assigned: false, is_complete: false, is_paid_for: false, is_verified: false, max_payment: "some updated max_payment", min_payment: "some updated min_payment", required_contractors: 43, specialty: "some updated specialty", title: "some updated title"}
    @invalid_attrs %{attachments: nil, category: nil, deadline: nil, description: nil, duration: nil, is_assigned: nil, is_complete: nil, is_paid_for: nil, is_verified: nil, max_payment: nil, min_payment: nil, required_contractors: nil, specialty: nil, title: nil}

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Orders.create_order()

      order
    end

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Orders.create_order(@valid_attrs)
      assert order.attachments == []
      assert order.category == "some category"
      assert order.deadline == ~D[2010-04-17]
      assert order.description == "some description"
      assert order.duration == "some duration"
      assert order.is_assigned == true
      assert order.is_complete == true
      assert order.is_paid_for == true
      assert order.is_verified == true
      assert order.max_payment == "some max_payment"
      assert order.min_payment == "some min_payment"
      assert order.required_contractors == 42
      assert order.specialty == "some specialty"
      assert order.title == "some title"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, %Order{} = order} = Orders.update_order(order, @update_attrs)
      assert order.attachments == []
      assert order.category == "some updated category"
      assert order.deadline == ~D[2011-05-18]
      assert order.description == "some updated description"
      assert order.duration == "some updated duration"
      assert order.is_assigned == false
      assert order.is_complete == false
      assert order.is_paid_for == false
      assert order.is_verified == false
      assert order.max_payment == "some updated max_payment"
      assert order.min_payment == "some updated min_payment"
      assert order.required_contractors == 43
      assert order.specialty == "some updated specialty"
      assert order.title == "some updated title"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end

  describe "order_offers" do
    alias Eworks.Orders.OrderOffer

    @valid_attrs %{asking_mount: "some asking_mount", is_accepted: true, is_pending: true, is_rejected: true}
    @update_attrs %{asking_mount: "some updated asking_mount", is_accepted: false, is_pending: false, is_rejected: false}
    @invalid_attrs %{asking_mount: nil, is_accepted: nil, is_pending: nil, is_rejected: nil}

    def order_offer_fixture(attrs \\ %{}) do
      {:ok, order_offer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Orders.create_order_offer()

      order_offer
    end

    test "list_order_offers/0 returns all order_offers" do
      order_offer = order_offer_fixture()
      assert Orders.list_order_offers() == [order_offer]
    end

    test "get_order_offer!/1 returns the order_offer with given id" do
      order_offer = order_offer_fixture()
      assert Orders.get_order_offer!(order_offer.id) == order_offer
    end

    test "create_order_offer/1 with valid data creates a order_offer" do
      assert {:ok, %OrderOffer{} = order_offer} = Orders.create_order_offer(@valid_attrs)
      assert order_offer.asking_mount == "some asking_mount"
      assert order_offer.is_accepted == true
      assert order_offer.is_pending == true
      assert order_offer.is_rejected == true
    end

    test "create_order_offer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order_offer(@invalid_attrs)
    end

    test "update_order_offer/2 with valid data updates the order_offer" do
      order_offer = order_offer_fixture()
      assert {:ok, %OrderOffer{} = order_offer} = Orders.update_order_offer(order_offer, @update_attrs)
      assert order_offer.asking_mount == "some updated asking_mount"
      assert order_offer.is_accepted == false
      assert order_offer.is_pending == false
      assert order_offer.is_rejected == false
    end

    test "update_order_offer/2 with invalid data returns error changeset" do
      order_offer = order_offer_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order_offer(order_offer, @invalid_attrs)
      assert order_offer == Orders.get_order_offer!(order_offer.id)
    end

    test "delete_order_offer/1 deletes the order_offer" do
      order_offer = order_offer_fixture()
      assert {:ok, %OrderOffer{}} = Orders.delete_order_offer(order_offer)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order_offer!(order_offer.id) end
    end

    test "change_order_offer/1 returns a order_offer changeset" do
      order_offer = order_offer_fixture()
      assert %Ecto.Changeset{} = Orders.change_order_offer(order_offer)
    end
  end
end
