defmodule Eworks.Collaborations.API do
  @moduledoc """
    Provides the api functions for handling the invites
  """
  import Ecto.Query, warn: false
  alias Eworks.Accounts.User
  alias Eworks.{Collaborations, Repo, Notifications}
  alias Eworks.Collaborations.{Invite, InviteOffer}
  alias EworksWeb.Endpoint
  alias Eworks.Utils.{Mailer, NewEmail}

  @doc """
    Gets a given invvitation
  """
  def get_invite(%User{} = user, %Invite{} = invite) do
    # checki if user is owner
    if user.id == invite.user_id do
      Repo.preload(invite, [invite_offers: from(offer in InviteOffer, where: offer.is_cancelled == false and offer.is_rejected == false)])
    else
      # return the invite
      invite
    end # end of invite.
  end # end of get invite

  @doc """
    Creates an invite
  """
  def create_invite(%User{} = user, order_id, invite_params) do
    # preload the user work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # create the invite
    with {:ok, invite} <- profile |> Ecto.build_assoc(:invites, %{order_id: order_id}) |> Collaborations.create_invite(invite_params) do
      # preload the offers
      invite = Repo.preload(invite, [:collaboration_offers])
      # return resutl
      {:ok, invite}
    end # end of with
  end # end of create invite

  @doc """
    Adds payment information about an invite
  """
  def update_invite_payment(%User{} = user, %Invite{} = invite, payment_params) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
      # update the order
      with {:ok, invite} = result <- Collaborations.update_invite_payment(invite, payment_params) do
        # preload the offers
        invite = Repo.preload(invite, [:collaboration_offers])
        # return resutl
        {:ok, invite}
      end # end of with
    else
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the invite
  end # end of update invite information

  @doc """
    Creates a new order offer
  """
  def create_invite_offer(%User{} = user, %Invite{} = invite) do
    # preload work profile of the curent user
    user = Repo.preload(user, [:work_profile])
    # create invite offer
    offer = user
    # add the owner information
    |> Ecto.build_assoc(:invite_offers, %{
      # add invite id
      invite_id: invite.id,
      owner_name: user.full_name,
      rating: user.work_profile.rating,
      owner_about: user.work_profile.cover_letter,
      owner_profile_pic: upload_url(Eworks.Uploaders.ProfilePicture.url({user.profile_pic, user}))
    })
    # create the offer
    |> Repo.insert!()
    # return ok
    {:ok, offer}
  end # end of create invite

  @doc """
    Reject an invite offer
  """
  def reject_invite_offer(%User{} = user, %Invite{} = invite, offer_id) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
      # start task to reject the offe
      Task.start(fn ->
        # get the offer
        [offer | _rest] = Repo.preload(invite, [collaboration_offers: from(offer in InviteOffer, where: offer.id == ^offer_id)]).collaboration_offers
        # reject the offer
        with offer <- offer |> Ecto.Changeset.change(%{is_rejected: true, is_pending: false}) |> Repo.update!() do
          # create a notificaiton
          {:ok, notification} = Notifications.create_notification(%{
            user_id: offer.user_id,
            asset_type: "Offer",
            asset_id: offer.id,
            notification_type: "Collaboration Invite Offer Rjection",
            message: "#{user.full_name} has rejected your collaboration offer request for **INVITE::#{invite.category}**"
          })
          # send the notification
          Endpoint.broadcast!("user:#{offer.user_id}", "notification::invite_offer_rejection", %{notification: render_notification(notification)})
        end # end of with
      end) # end of task

      # return :ok
      {:ok, invite}
    else
      {:error, :not_owner}
    end # end of checking if the currernt user is the owner of the offer
  end # end of reject

  @doc """
    Function for accepting an invite offer and also adds the user to the assigned orders
  """
  def accept_invite_offer(%User{} = user, %Invite{} = invite, offer_id) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # get the offer and its user
    [offer | _rest] = Repo.preload(invite, [collaboration_offers: from(offer in InviteOffer, where: offer.id == ^offer_id)]).collaboration_offers
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
      # gett eh owner of the offer
      offer_owner = Repo.preload(offer, [:user]).user
      # check if the user has been suspended
      if not offer_owner.is_suspended do
        # accept the offer
        with _offer <- offer |> Ecto.Changeset.change(%{is_accepted: true, is_pending: true}) |> Repo.update!() do
          # send a notification to the owner of the invite offer using websocket
          Task.start(fn ->
            # creare message for notification
            message = "#{user.full_name} has accepted your collaboration offer. **INVITE::#{invite.category}**"
            # send an email notification about the accepting of the invite offer accepting
            NewEmail.new_email_notification(offer_owner, "Collaboration Offer Acceptance", "#{message} \n Login to your account to view more details.")
            # send the email
            |> Mailer.deliver_later()

            # create a notification about the accepting of the oofer
            {:ok, notification} = Notifications.create_notification(%{
              user_id: offer_owner.id,
              asset: "Invite Offer",
              asset_type: "Collaboration Invite Offer",
              notification_type: "Collaboration Offer Accepance",
              asset_id: invite.id,
              message: message
            })
            # send the notificaiton to the owner
            Endpoint.broadcast!("user:#{offer_owner.id}", "notification::invite_offer_acceptance", %{notification: render_notification(notification)})
          end) # end of task

          # update the invite
          updated_invite = if invite.required_collaborators == invite.already_accepted + 1 do
            invite
            # update the invite by adding the already assigned by one
            |> Ecto.Changeset.change(%{
              already_accepted: invite.already_accepted + 1,
              is_assigned: true,
              collaborators: [offer_owner.id | invite.collaborators]
            })
            # update the order
            |> Repo.update!()
            # preload the offers
            |> Repo.preload([collaboration_offers: from(offer in InviteOffer, where: offer.is_accepted == true)])
          else # the invite is not yet fully assigned
            invite
            # update the invite by adding the already assigned by one
            |> Ecto.Changeset.change(%{
              already_accepted: invite.already_accepted + 1,
              collaborators: [offer_owner.id | invite.collaborators]
            })
            # update the order
            |> Repo.update!()
            # preload the offers
            |> Repo.preload([collaboration_offers: from(offer in InviteOffer, where: offer.is_cancelled == false and offer.is_rejected == false)])
          end # end of checking if the invite is completely assigned

          # return the invite
          {:ok, updated_invite}
        end # end of with for updating the offer

      # user is suspended
      else
        {:error, :user_suspended, offer_owner.name}
      end # end of if for checking if the user is suspende or not

    # user is not the owner of the job
    else
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the offer.
  end # end of accepting an offer

  # function for cancelling an invitations
  def cancel_invite(%User{} = user, %Invite{} = invite) do
    # ensure the current user is the owner of the invite
    if user.id == invite.user_id do
       # cacnel the order
       with invite <- invite |> Ecto.Changeset.change(%{is_cancelled: true}) |> Repo.update!() do
        # task for notifying the users who have invite offers
        Task.start(fn ->
          # preload the offers
          offers = Repo.preload(invite, [invite_offers: from(offer in InviteOffer, where: offer.is_cancelled == false and offer.is_rejected == false)]).invite_offers
          # only send notifications to the owner of the offers if the offers is not empty
          with false <- Enum.empty?(offers) do
            # for each of the offers, reject and notify the user
            Stream.each(offers, fn offer ->
              Task.start(fn ->
                # reject the offer
                offer = offer |> Ecto.Changeset.change(%{is_rejected: true, is_pending: false}) |> Repo.update!()
                # create a notification
                {:ok, notification} = Notifications.create_notification(%{
                  user_id: offer.user_id,
                  asset_type: :offer,
                  asset_id: offer.id,
                  message: "Your collaboration invite offer has been rejected because the collaboration request was cancelled by owner."
                })
                # send notification
                Endpoint.broadcast("user:#{offer.user_id}", "notification::invite_offer_rejection", %{notification: render_notification(notification)})
              end) # end of task for each offer
            end) # end of stream.each
            # run the stream
            |> Stream.run()
          end
        end) # end of task
        # return :ok
        {:ok, invite}
       end # end of cacncelling an invite
    else
      {:error, :not_owner}
    end
  end # end of cance invite

  @doc """
    Cancels the an offer invite
  """
  def cancel_invite_offer(%User{} = user, offer_id) do
    # get the offer
    [offer | _rest] = Repo.preload(user, [invite_offers: from(offer in InviteOffer, where: offer.id == ^offer_id)]).invite_offers
    # cancel the order
    offer = offer |> Ecto.Changeset.change(%{is_cancelled: true, is_pending: false}) |> Repo.update!()
    # return the offer
    {:ok, offer}
  end # end of cancelling an offer


  ############################## PRIVATE FUNCTIONS ######################
  defp upload_url(url) do
    if url, do: url |> String.split("?") |> List.first(), else: nil
  end

  # render_notification
  defp render_notification(notification) do
    %{
      user_id: notification.user_id,
      asset_type: notification.asset_type,
      asset_id: notification.id,
      message: notification.message
    }
  end # end of notificaiton



end # end of module
