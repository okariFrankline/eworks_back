defmodule EworksWeb.DirectHireController do
  use EworksWeb, :controller

  alias Eworks.Requests
  alias Eworks.Requests.DirectHire

  action_fallback EworksWeb.FallbackController

  @doc """
    Returns a list of requests made the current user
  """
  def list_client_direct_hires(conn, _params, user) do
    with {:ok, hires} <- API.list_direct_hires(:client, user) do
      # return the reuslt
      conn
      # put the status
      |> put_status(:ok)
      # render the hires
      |> render("contractor_hires.json", hires: hires)
    end # end of direct hires
  end # end of list my_direct hires

  @doc """
    Returns a list of all the direct hire requests made to a given contractor
  """
  def list_contractor_direct_hires(conn, _params, user) do
    with {:ok, hires} <- API.list_direct_hires(:contractor, user) do
      # return the reuslt
      conn
      # put the status
      |> put_status(:ok)
      # render the hires
      |> render("contractor_hires.json", hires: hires)
    end # end of direct hires
  end # end of list contractors direct_hires

  def index(conn, _params) do
    direct_hires = Requests.list_direct_hires()
    render(conn, "index.json", direct_hires: direct_hires)
  end

  def create(conn, %{"direct_hire" => direct_hire_params}) do
    with {:ok, %DirectHire{} = direct_hire} <- Requests.create_direct_hire(direct_hire_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.direct_hire_path(conn, :show, direct_hire))
      |> render("show.json", direct_hire: direct_hire)
    end
  end

  def show(conn, %{"id" => id}) do
    direct_hire = Requests.get_direct_hire!(id)
    render(conn, "show.json", direct_hire: direct_hire)
  end

  def update(conn, %{"id" => id, "direct_hire" => direct_hire_params}) do
    direct_hire = Requests.get_direct_hire!(id)

    with {:ok, %DirectHire{} = direct_hire} <- Requests.update_direct_hire(direct_hire, direct_hire_params) do
      render(conn, "show.json", direct_hire: direct_hire)
    end
  end

  def delete(conn, %{"id" => id}) do
    direct_hire = Requests.get_direct_hire!(id)

    with {:ok, %DirectHire{}} <- Requests.delete_direct_hire(direct_hire) do
      send_resp(conn, :no_content, "")
    end
  end
end
