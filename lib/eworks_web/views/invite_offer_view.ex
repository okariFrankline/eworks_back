defmodule EworksWeb.InviteOfferView do
  use EworksWeb, :view
  alias EworksWeb.InviteOfferView

  def render("index.json", %{invite_offers: invite_offers}) do
    %{data: render_many(invite_offers, InviteOfferView, "invite_offer.json")}
  end

  def render("show.json", %{invite_offer: invite_offer}) do
    %{data: render_one(invite_offer, InviteOfferView, "invite_offer.json")}
  end

  def render("invite_offer.json", %{invite_offer: invite_offer}) do
    %{id: invite_offer.id,
      asking_amount: invite_offer.asking_amount,
      is_pending: invite_offer.is_pending,
      is_cancelled: invite_offer.is_cancelled,
      is_rejected: invite_offer.is_rejected,
      is_accepted: invite_offer.is_accepted}
  end
end
