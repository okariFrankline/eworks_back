defmodule EworksWeb.DirectHireControllerTest do
  use EworksWeb.ConnCase

  alias Eworks.Requests
  alias Eworks.Requests.DirectHire

  @create_attrs %{
    is_accepted: true,
    is_assigned: true
  }
  @update_attrs %{
    is_accepted: false,
    is_assigned: false
  }
  @invalid_attrs %{is_accepted: nil, is_assigned: nil}

  def fixture(:direct_hire) do
    {:ok, direct_hire} = Requests.create_direct_hire(@create_attrs)
    direct_hire
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all direct_hires", %{conn: conn} do
      conn = get(conn, Routes.direct_hire_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create direct_hire" do
    test "renders direct_hire when data is valid", %{conn: conn} do
      conn = post(conn, Routes.direct_hire_path(conn, :create), direct_hire: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.direct_hire_path(conn, :show, id))

      assert %{
               "id" => id,
               "is_accepted" => true,
               "is_assigned" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.direct_hire_path(conn, :create), direct_hire: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update direct_hire" do
    setup [:create_direct_hire]

    test "renders direct_hire when data is valid", %{conn: conn, direct_hire: %DirectHire{id: id} = direct_hire} do
      conn = put(conn, Routes.direct_hire_path(conn, :update, direct_hire), direct_hire: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.direct_hire_path(conn, :show, id))

      assert %{
               "id" => id,
               "is_accepted" => false,
               "is_assigned" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, direct_hire: direct_hire} do
      conn = put(conn, Routes.direct_hire_path(conn, :update, direct_hire), direct_hire: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete direct_hire" do
    setup [:create_direct_hire]

    test "deletes chosen direct_hire", %{conn: conn, direct_hire: direct_hire} do
      conn = delete(conn, Routes.direct_hire_path(conn, :delete, direct_hire))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.direct_hire_path(conn, :show, direct_hire))
      end
    end
  end

  defp create_direct_hire(_) do
    direct_hire = fixture(:direct_hire)
    %{direct_hire: direct_hire}
  end
end
