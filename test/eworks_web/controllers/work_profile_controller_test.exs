defmodule EworksWeb.WorkProfileControllerTest do
  use EworksWeb.ConnCase

  alias Eworks.Profiles
  alias Eworks.Profiles.WorkProfile

  @create_attrs %{
    job_hires: 42,
    professional_intro: "some professional_intro",
    rating: 42,
    skills: [],
    success_rate: 42
  }
  @update_attrs %{
    job_hires: 43,
    professional_intro: "some updated professional_intro",
    rating: 43,
    skills: [],
    success_rate: 43
  }
  @invalid_attrs %{job_hires: nil, professional_intro: nil, rating: nil, skills: nil, success_rate: nil}

  def fixture(:work_profile) do
    {:ok, work_profile} = Profiles.create_work_profile(@create_attrs)
    work_profile
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all work_profiles", %{conn: conn} do
      conn = get(conn, Routes.work_profile_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create work_profile" do
    test "renders work_profile when data is valid", %{conn: conn} do
      conn = post(conn, Routes.work_profile_path(conn, :create), work_profile: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.work_profile_path(conn, :show, id))

      assert %{
               "id" => id,
               "job_hires" => 42,
               "professional_intro" => "some professional_intro",
               "rating" => 42,
               "skills" => [],
               "success_rate" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.work_profile_path(conn, :create), work_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update work_profile" do
    setup [:create_work_profile]

    test "renders work_profile when data is valid", %{conn: conn, work_profile: %WorkProfile{id: id} = work_profile} do
      conn = put(conn, Routes.work_profile_path(conn, :update, work_profile), work_profile: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.work_profile_path(conn, :show, id))

      assert %{
               "id" => id,
               "job_hires" => 43,
               "professional_intro" => "some updated professional_intro",
               "rating" => 43,
               "skills" => [],
               "success_rate" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, work_profile: work_profile} do
      conn = put(conn, Routes.work_profile_path(conn, :update, work_profile), work_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete work_profile" do
    setup [:create_work_profile]

    test "deletes chosen work_profile", %{conn: conn, work_profile: work_profile} do
      conn = delete(conn, Routes.work_profile_path(conn, :delete, work_profile))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.work_profile_path(conn, :show, work_profile))
      end
    end
  end

  defp create_work_profile(_) do
    work_profile = fixture(:work_profile)
    %{work_profile: work_profile}
  end
end
