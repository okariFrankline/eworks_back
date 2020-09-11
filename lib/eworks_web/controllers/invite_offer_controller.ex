defmodule EworksWeb.InviteOfferController do
  use EworksWeb, :controller

  alias Eworks.Collaborations
  alias Eworks.Collaborations.InviteOffer

  action_fallback EworksWeb.FallbackController

  def index(conn, _params) do
    invite_offers = Collaborations.list_invite_offers()
    render(conn, "index.json", invite_offers: invite_offers)
  end

  def create(conn, %{"invite_offer" => invite_offer_params}) do
    with {:ok, %InviteOffer{} = invite_offer} <- Collaborations.create_invite_offer(invite_offer_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.invite_offer_path(conn, :show, invite_offer))
      |> render("show.json", invite_offer: invite_offer)
    end
  end

  def show(conn, %{"id" => id}) do
    invite_offer = Collaborations.get_invite_offer!(id)
    render(conn, "show.json", invite_offer: invite_offer)
  end

  def update(conn, %{"id" => id, "invite_offer" => invite_offer_params}) do
    invite_offer = Collaborations.get_invite_offer!(id)

    with {:ok, %InviteOffer{} = invite_offer} <- Collaborations.update_invite_offer(invite_offer, invite_offer_params) do
      render(conn, "show.json", invite_offer: invite_offer)
    end
  end

  def delete(conn, %{"id" => id}) do
    invite_offer = Collaborations.get_invite_offer!(id)

    with {:ok, %InviteOffer{}} <- Collaborations.delete_invite_offer(invite_offer) do
      send_resp(conn, :no_content, "")
    end
  end
end
