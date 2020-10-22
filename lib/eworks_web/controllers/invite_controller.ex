defmodule EworksWeb.Invites.InviteController do
  use EworksWeb, :controller

  alias EworksWeb.Plugs
  alias Eworks.Collaborations.{Invite, API, InviteOffer}
  import Ecto.Query, warn: false
  alias Eworks.Repo

  plug Plugs.InviteById when action not in [
    :create_new_invite,
    :cancel_invite_offer,
    :list_invites_created_by_current_user,
    :list_current_user_invite_offers,
    :list_unassigned_invites,
    :list_invite_offers
  ]
  plug Plugs.CanSubmitOrderOffer when action in [:submit_invite_offer]

  action_fallback EworksWeb.FallbackController

  # action
  def action(conn, _) do
    # insert the current user and the invite into the arhs
    args = [conn, conn.params, conn.assigns.current_user, Map.get(conn.assigns, :invite)]
    # return the functon
    apply(__MODULE__, action_name(conn), args)
  end # end of action

  def create_new_invite(conn, %{"new_invite" => invite_params, "order_id" => order_id}, user, _invite) do
    with {:ok, %Invite{} = invite} = API.create_invite(user, order_id, invite_params) do
      conn
      # put status
      |> put_status(:created)
      # render the  invite
      |> render("invite.json", invite: invite)
    end # end of with
  end # end of create new invite

  @doc """
    Updates an invite's deadline and the required collaborators
  """
  def update_invite_category(conn, %{"new_invite" => %{"category" => params}}, user, invite) do
    with {:ok, %Invite{} = invite} <- API.update_invite_category(user, invite, params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the invite
      |> render("invite.json", invite: invite)
    end # end of with
  end # end of update_invite_payment

  @doc """
    Updates an invite's deadline and the required collaborators
  """
  def update_invite_deadline_collaborators(conn, %{"new_invite" => %{"deadline_collaborators" => params}}, user, invite) do
    with {:ok, %Invite{} = invite} <- API.update_invite_deadline_collaborators(user, invite, params) do
      conn
      # put the status
      |> put_status(:ok)
      # render the invite
      |> render("invite.json", invite: invite)
    end # end of with
  end # end of update_invite_payment

  @doc """
    Updates an invite's deadline and the required collaborators
  """
  def update_invite_description(conn, %{"new_invite" => %{"description" => description}}, user, invite) do
    with {:ok, %Invite{} = invite} <- API.update_invite_description(user, invite, description) do
      conn
      # put the status
      |> put_status(:ok)
      # render the invite
      |> render("invite.json", invite: invite)
    end # end of with
  end # end of update_invite_payment

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
    Sends a verification code to the user
  """
  def get_verification_code(conn, _params, user, invite) do
    API.send_verification_code(user, invite)
    # send a response
    conn
    # put status of ok
    |> put_status(:ok)
    # render success
    |> render("success.json", message: "Your Collaboration Invite verification code has been sennt to #{user.auth_email}")
  end # end of get verification code

  @doc """
    Resends a new verification code
  """
  def resend_verification_code(conn, _params, user, invite) do
    API.resend_verification_code(user, invite)
    # send a response
    conn
    # put status of ok
    |> put_status(:ok)
    # render success
    |> render("success.json", message: "A new Collaboration Invite verification code has been sent to #{user.auth_email}")
  end # end of resend verification code


  @doc """
    Verifies an invite
  """
  def verify_invite(conn, %{"verification_code" => code}, user, invite) do
    with {:ok, _invite} <- API.verify_invite(user, invite, code) do
      # return a succes meesage
      conn
      # put the status
      |> put_status(:ok)
      # render success
      |> render("success.json", message: "Success. Your Collaboration Invite has successfully being verified.")

    else
      {:error, :invalid_code} ->
        # return an error response
        conn
        # put the status
        |> put_status(:bad_request)
        # put the error view
        |> put_view(EworksWeb.ErrorView)
        # render the failed
        |> render("failed.json", message: "Failed. The verification code entered is invalid. Please try again.")
    end
  end

  @doc """
    Submits an offer for an invite
  """
  def submit_invite_offer(conn, %{"asking_amount" => asking_amount}, user, invite) do
    with {:ok, offer} <- API.create_invite_offer(user, invite, asking_amount) do
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
      |> render("invite.json", invite: invite, user: user)
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
    |> render("success.json", message: "Collaboratioin invite successfully cancelled.")
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
      |> render("success.json", message: "Offer successfully rejected.")
    end # end of with
  end # end of reject invite offer

  @doc """
    Gets all invites created by the given user
  """
  def list_invites_created_by_current_user(conn, %{next_cursor: cursor}, user, _invite) do
    query = from(
      invite in Invite,
      # ensure the user id is ismilar to that of the current user
      where: invite.user_id == ^user.id and invite.is_cancelled == false,
      # order by the inserted at
      order_by: [desc: invite.inserted_at]
    )

    # check if the cursor is given
    page = if cursor == "false" do
      # return the first 10 invites
      Repo.paginate(query, cursor_fields: [:inserted_at], limit: 10)
    else
      # return the list of invites from the last known corsor
       Repo.paginate(query, after: cursor, cursor_fields: [:inserted_at], limit: 10)
    end

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("my_invites.json", invites: page.entries, next_cursor: page.metadata.after)
  end # end of function

  @doc """
    Returns a list of invites to be diaplayed that are not assiigned
  """
  def list_unassigned_invites(conn, %{"next_cursor" => cursor}, user, _invite) do
    # query for the invites
    query = from(
      invite in Invite,
      # ensure the user id is ismilar to that of the current user
      where: invite.is_assigned == false and invite.is_cancelled == false and invite.user_id != ^user.id,
      # order by the inserted at
      order_by: [desc: invite.inserted_at]
    )

    # check if the cursor is given
    page = if cursor == "false" do
      # return the first 10 invites
      Repo.paginate(query, cursor_fields: [:inserted_at], limit: 10)
    else
      # return the list of invites from the last known corsor
       Repo.paginate(query, after: cursor, cursor_fields: [:inserted_at], limit: 10)
    end

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the results
    |> render("display_invites.json", invites: page.entries, next_cursor: page.metadata.after)
  end # end of list unassigned invites

  @doc """
    Returns the current user's collaboration invites
  """
  def list_current_user_invite_offers(conn, %{"filter" => filter}, user, _invite) do
    # get the offers
    offers = case filter do
      # return the pending offers
      "pending" ->
        Repo.preload(user, [invite_offers: from(offer in InviteOffer, where: offer.is_pending == true)])

      # return the accepted offers
      "accepted" ->
        Repo.preload(user, [invite_offers: from(offer in InviteOffer, where: offer.is_accepted == true)])

      # return the rejected offers
      "rejected" ->
        Repo.preload(user, [invite_offers: from(offer in InviteOffer, where: offer.is_rejected == true)])
    end # end of case

    # return the results
    conn
    # put the status
    |> put_status(:ok)
    # render the offers
    |> render("my_offers.json", offers: offers)
  end

  @doc """
    List order offers
  """
  def list_invite_offers(conn, %{"next_cursor" => next_cursor, "invite_id" => id, "filter" => filter}, _user, _invite) do
    # query for the offers
    query = from(
      invite in InviteOffer,
      # ensure the order id is simialr to the offers
      where: invite.order_id == ^id,
      # order
      order_by: [desc: invite.inserted_at]
    )

    # check the filter
    query = case filter do
      "pending" ->
        # filter the query
        from(invite in query, where: invite.pending == true and invite.cancelled == false and invite.is_rejected == false)

      # accepted offers
      "accepted" ->
        # get the accepted offers
        from(invite in query, where: invite.accepted == true and invite.cancelled == false and invite.is_rejected == false)
    end # get the fitler

    # check the value of the next cursor
    page = if next_cursor != "false" do
      Repo.paginate(query, cursor_fields: [:inserted_at], limit: 10)
    else
      Repo.paginate(query, after: next_cursor, cursor_fields: [:inserted_at], limit: 10)
    end # end of next cursor

    # return the result
    conn
    # return the rsult
    |> put_status(:ok)
    # return the results
    |> render("offers.json", offers: page.entries, next_cursor: page.metadata.after)

  end # retun the

  @doc """
    Returns a given invite
  """
  def get_invite(conn, _params, user, invite) do
    with invite <- API.get_invite(user, invite) do
      # returna a result
      conn
      # put the status
      |> put_status(:ok)
      # render the invite
      |> render("invite.json", invite: invite)
    end
  end # end of get invite

end # end of module
