defmodule EworksWeb.InviteController do
  use EworksWeb, :controller

  alias EworksWeb.Plugs
  alias Eworks.Collaborations.{Invite, API}

  plug Plugs.InviteById when action not in [:create_new_invite]
  plug Plugs.CanSubmitOrderOffer when action in [:submit_invite_offer]
  action_fallback EworksWeb.FallbackController

  # action
  def action(conn, _) do
    # insert the current user and the invite into the arhs
    args = [conn, conn.args, conn.assigns.current_user, Map.get(conn.assigns, :invite)]
    # return the functon
    apply(__MODULE__, action_name(conn), args)
  end # end of action

  def create_new_invite(conn, %{"new_invite" => invite_params, "invite_id" => invite_id}, user, _invite) do
    with {:ok, %Invite{} = invite} = API.create_invite(user, invite_id, invite_params) do
      conn
      # put status
      |> put_status(:created)
      # render the  invite
      |> render("invite.json", invite: invite)
    end # end of with
  end # end of create new invite

  @doc """
    Updates an invites payment informarion
  """
  def update_invite_payment(conn, %{"new_invite" => %{"payment" => payment_params}}, user, invite) do
    with {:ok, %Invite{} = invite} <- API.update_invite_payment(user, invite, payment_params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the invite
      |> render("invite.json", invite: invite)
    end # end of with
  end # end of update_invite_payment

  @doc """
    Submits an offer for an invite
  """
  def submit_invite_offer(conn, _params, user, invite) do
    with {:ok, offer} <- API.create_invite_offer(user, invite) do
      conn
      # put status
      |> put_status(:created)
      # render the offer
      |> render("invite_offer.json", offer: offer)
    end # end of with
  end # end of submit invite ffer

  @doc """
    Accepts an invitation offer
  """
  def accept_invite_offer(conn, %{"invite_offer_id" => id}, user, invite) do
    with {:ok, invite} <- API.accept_invite_offer(user, invite, id) do
      conn
      # put status
      |> put_status(:ok)
      # render the invite
      |> render("invite.json", invite: invite)
    end # end of with
  end # end of accepting offer invite

  @doc """
    Cacncels an invitation offer
  """
  def cancel_invite_offer(conn, %{"invite_offer_id" => id}, user, _invite) do
    {:ok, _offer} =  API.cancel_invite_offer(user, id)
    # render the page
    conn
    # put the status
    |> put_status(:ok)
    # render succes
    |> render("success.json")
  end # end of cancel_invitaion_offeer

  @doc """
    Cancels an invite
  """
  def cancel_invite(conn, _params, user, invite) do
    with {:ok, _invite} <- API.cancel_invite(user, invite) do
      conn
      # put the status
      |> put_status(:ok)
      # render success
      |> render("success.json")
    end # end of with
  end # end of canceling an invite

  @doc """
    rejct invite offer
  """
  def reject_invite_offer(conn, %{"invite_offer_id" => id}, user, order) do
    with {:ok, _invite} <- API.reject_invite_offer(user, order, id) do
      conn
      # put status
      |> put_status(:ok)
      # render the success
      |> render("success.json")
    end # end of with
  end # end of reject invite offer

end
