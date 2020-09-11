defmodule EworksWeb.InviteOfferControllerTest do
  use EworksWeb.ConnCase

  alias Eworks.Collaborations
  alias Eworks.Collaborations.InviteOffer

  @create_attrs %{
    asking_amount: 42,
    is_accepted: true,
    is_cancelled: true,
    is_pending: true,
    is_rejected: true
  }
  @update_attrs %{
    asking_amount: 43,
    is_accepted: false,
    is_cancelled: false,
    is_pending: false,
    is_rejected: false
  }
  @invalid_attrs %{asking_amount: nil, is_accepted: nil, is_cancelled: nil, is_pending: nil, is_rejected: nil}

  def fixture(:invite_offer) do
    {:ok, invite_offer} = Collaborations.create_invite_offer(@create_attrs)
    invite_offer
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all invite_offers", %{conn: conn} do
      conn = get(conn, Routes.invite_offer_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create invite_offer" do
    test "renders invite_offer when data is valid", %{conn: conn} do
      conn = post(conn, Routes.invite_offer_path(conn, :create), invite_offer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.invite_offer_path(conn, :show, id))

      assert %{
               "id" => id,
               "asking_amount" => 42,
               "is_accepted" => true,
               "is_cancelled" => true,
               "is_pending" => true,
               "is_rejected" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.invite_offer_path(conn, :create), invite_offer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update invite_offer" do
    setup [:create_invite_offer]

    test "renders invite_offer when data is valid", %{conn: conn, invite_offer: %InviteOffer{id: id} = invite_offer} do
      conn = put(conn, Routes.invite_offer_path(conn, :update, invite_offer), invite_offer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.invite_offer_path(conn, :show, id))

      assert %{
               "id" => id,
               "asking_amount" => 43,
               "is_accepted" => false,
               "is_cancelled" => false,
               "is_pending" => false,
               "is_rejected" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, invite_offer: invite_offer} do
      conn = put(conn, Routes.invite_offer_path(conn, :update, invite_offer), invite_offer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete invite_offer" do
    setup [:create_invite_offer]

    test "deletes chosen invite_offer", %{conn: conn, invite_offer: invite_offer} do
      conn = delete(conn, Routes.invite_offer_path(conn, :delete, invite_offer))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.invite_offer_path(conn, :show, invite_offer))
      end
    end
  end

  defp create_invite_offer(_) do
    invite_offer = fixture(:invite_offer)
    %{invite_offer: invite_offer}
  end
end
