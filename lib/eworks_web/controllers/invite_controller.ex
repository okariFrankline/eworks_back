defmodule EworksWeb.InviteController do
  use EworksWeb, :controller

  alias Eworks.Collaborations
  alias Eworks.Collaborations.Invite

  action_fallback EworksWeb.FallbackController

  def index(conn, _params) do
    invites = Collaborations.list_invites()
    render(conn, "index.json", invites: invites)
  end

  def create(conn, %{"invite" => invite_params}) do
    with {:ok, %Invite{} = invite} <- Collaborations.create_invite(invite_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.invite_path(conn, :show, invite))
      |> render("show.json", invite: invite)
    end
  end

  def show(conn, %{"id" => id}) do
    invite = Collaborations.get_invite!(id)
    render(conn, "show.json", invite: invite)
  end

  def update(conn, %{"id" => id, "invite" => invite_params}) do
    invite = Collaborations.get_invite!(id)

    with {:ok, %Invite{} = invite} <- Collaborations.update_invite(invite, invite_params) do
      render(conn, "show.json", invite: invite)
    end
  end

  def delete(conn, %{"id" => id}) do
    invite = Collaborations.get_invite!(id)

    with {:ok, %Invite{}} <- Collaborations.delete_invite(invite) do
      send_resp(conn, :no_content, "")
    end
  end
end
