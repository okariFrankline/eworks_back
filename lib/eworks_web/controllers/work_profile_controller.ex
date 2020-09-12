defmodule EworksWeb.WorkProfileController do
  use EworksWeb, :controller

  alias Eworks.Profiles
  alias Eworks.Profiles.WorkProfile

  action_fallback EworksWeb.FallbackController

  def index(conn, _params) do
    work_profiles = Profiles.list_work_profiles()
    render(conn, "index.json", work_profiles: work_profiles)
  end

  def create(conn, %{"work_profile" => work_profile_params}) do
    with {:ok, %WorkProfile{} = work_profile} <- Profiles.create_work_profile(work_profile_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.work_profile_path(conn, :show, work_profile))
      |> render("show.json", work_profile: work_profile)
    end
  end

  def show(conn, %{"id" => id}) do
    work_profile = Profiles.get_work_profile!(id)
    render(conn, "show.json", work_profile: work_profile)
  end

  def update(conn, %{"id" => id, "work_profile" => work_profile_params}) do
    work_profile = Profiles.get_work_profile!(id)

    with {:ok, %WorkProfile{} = work_profile} <- Profiles.update_work_profile(work_profile, work_profile_params) do
      render(conn, "show.json", work_profile: work_profile)
    end
  end

  def delete(conn, %{"id" => id}) do
    work_profile = Profiles.get_work_profile!(id)

    with {:ok, %WorkProfile{}} <- Profiles.delete_work_profile(work_profile) do
      send_resp(conn, :no_content, "")
    end
  end
end
