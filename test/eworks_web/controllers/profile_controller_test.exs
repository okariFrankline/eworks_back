defmodule EworksWeb.ProfileControllerTest do
  use EworksWeb.ConnCase

  alias Eworks.Accounts
  alias Eworks.Accounts.Profile

  @create_attrs %{
    about: "some about",
    city: "some city",
    company_name: "some company_name",
    country: "some country",
    emails: [],
    first_name: "some first_name",
    last_name: "some last_name",
    phones: [],
    profile_pic: "some profile_pic"
  }
  @update_attrs %{
    about: "some updated about",
    city: "some updated city",
    company_name: "some updated company_name",
    country: "some updated country",
    emails: [],
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    phones: [],
    profile_pic: "some updated profile_pic"
  }
  @invalid_attrs %{about: nil, city: nil, company_name: nil, country: nil, emails: nil, first_name: nil, last_name: nil, phones: nil, profile_pic: nil}

  def fixture(:profile) do
    {:ok, profile} = Accounts.create_profile(@create_attrs)
    profile
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all profiles", %{conn: conn} do
      conn = get(conn, Routes.profile_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create profile" do
    test "renders profile when data is valid", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :create), profile: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.profile_path(conn, :show, id))

      assert %{
               "id" => id,
               "about" => "some about",
               "city" => "some city",
               "company_name" => "some company_name",
               "country" => "some country",
               "emails" => [],
               "first_name" => "some first_name",
               "last_name" => "some last_name",
               "phones" => [],
               "profile_pic" => "some profile_pic"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :create), profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update profile" do
    setup [:create_profile]

    test "renders profile when data is valid", %{conn: conn, profile: %Profile{id: id} = profile} do
      conn = put(conn, Routes.profile_path(conn, :update, profile), profile: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.profile_path(conn, :show, id))

      assert %{
               "id" => id,
               "about" => "some updated about",
               "city" => "some updated city",
               "company_name" => "some updated company_name",
               "country" => "some updated country",
               "emails" => [],
               "first_name" => "some updated first_name",
               "last_name" => "some updated last_name",
               "phones" => [],
               "profile_pic" => "some updated profile_pic"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, profile: profile} do
      conn = put(conn, Routes.profile_path(conn, :update, profile), profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete profile" do
    setup [:create_profile]

    test "deletes chosen profile", %{conn: conn, profile: profile} do
      conn = delete(conn, Routes.profile_path(conn, :delete, profile))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.profile_path(conn, :show, profile))
      end
    end
  end

  defp create_profile(_) do
    profile = fixture(:profile)
    %{profile: profile}
  end
end
