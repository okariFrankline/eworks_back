defmodule EworksWeb.InviteControllerTest do
  use EworksWeb.ConnCase

  alias Eworks.Collaborations
  alias Eworks.Collaborations.Invite

  @create_attrs %{
    collaborators_needed: 42,
    deadline: ~D[2010-04-17],
    is_paid_for: true,
    is_verified: true,
    payable_amount: "some payable_amount",
    title: "some title",
    verification_code: 42
  }
  @update_attrs %{
    collaborators_needed: 43,
    deadline: ~D[2011-05-18],
    is_paid_for: false,
    is_verified: false,
    payable_amount: "some updated payable_amount",
    title: "some updated title",
    verification_code: 43
  }
  @invalid_attrs %{collaborators_needed: nil, deadline: nil, is_paid_for: nil, is_verified: nil, payable_amount: nil, title: nil, verification_code: nil}

  def fixture(:invite) do
    {:ok, invite} = Collaborations.create_invite(@create_attrs)
    invite
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all invites", %{conn: conn} do
      conn = get(conn, Routes.invite_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create invite" do
    test "renders invite when data is valid", %{conn: conn} do
      conn = post(conn, Routes.invite_path(conn, :create), invite: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.invite_path(conn, :show, id))

      assert %{
               "id" => id,
               "collaborators_needed" => 42,
               "deadline" => "2010-04-17",
               "is_paid_for" => true,
               "is_verified" => true,
               "payable_amount" => "some payable_amount",
               "title" => "some title",
               "verification_code" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.invite_path(conn, :create), invite: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update invite" do
    setup [:create_invite]

    test "renders invite when data is valid", %{conn: conn, invite: %Invite{id: id} = invite} do
      conn = put(conn, Routes.invite_path(conn, :update, invite), invite: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.invite_path(conn, :show, id))

      assert %{
               "id" => id,
               "collaborators_needed" => 43,
               "deadline" => "2011-05-18",
               "is_paid_for" => false,
               "is_verified" => false,
               "payable_amount" => "some updated payable_amount",
               "title" => "some updated title",
               "verification_code" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, invite: invite} do
      conn = put(conn, Routes.invite_path(conn, :update, invite), invite: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete invite" do
    setup [:create_invite]

    test "deletes chosen invite", %{conn: conn, invite: invite} do
      conn = delete(conn, Routes.invite_path(conn, :delete, invite))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.invite_path(conn, :show, invite))
      end
    end
  end

  defp create_invite(_) do
    invite = fixture(:invite)
    %{invite: invite}
  end
end
