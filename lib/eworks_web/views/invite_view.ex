defmodule EworksWeb.InviteView do
  use EworksWeb, :view
  alias EworksWeb.InviteView

  def render("index.json", %{invites: invites}) do
    %{data: render_many(invites, InviteView, "invite.json")}
  end

  def render("show.json", %{invite: invite}) do
    %{data: render_one(invite, InviteView, "invite.json")}
  end

  def render("invite.json", %{invite: invite}) do
    %{id: invite.id,
      title: invite.title,
      payable_amount: invite.payable_amount,
      deadline: invite.deadline,
      is_verified: invite.is_verified,
      verification_code: invite.verification_code,
      is_paid_for: invite.is_paid_for,
      collaborators_needed: invite.collaborators_needed}
  end
end
