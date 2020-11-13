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
  alias Eworks.API.Utils

  @doc """
    Gets a given invvitation
  """
  def get_invite(%User{} = user, %Invite{} = invite) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # checki if user is owner
    if profile.id == invite.work_profile_id, do: invite, else: {:error, :not_owner}
  end # end of get invite

  @doc """
    Creates an invite
  """
  def create_invite(%User{} = user, order_id, invite_params) do
    # preload the user work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # create the invite
    with {:ok, _invite} = result <- profile |> Ecto.build_assoc(:invites, %{order_id: order_id, owner_name: user.full_name}) |> Collaborations.create_invite(invite_params), do: result
  end # end of create invite

  @doc """
    Updates the invite's category and specialty
  """
  def update_invite_category(%User{} = user, %Invite{} = invite, params) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
      # update the order
      with {:ok, _invite} = result <- Collaborations.update_invite_category(invite, params), do: result
    else
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the invite
  end # end of update incite deadline
  @doc """
    Adds the deadline and the required number of collaborators
  """
  def update_invite_deadline_collaborators(%User{} = user, %Invite{} = invite, params) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
      # update the order
      with {:ok, _invite} = result <- Collaborations.update_invite_deadline_collaborator(invite, params), do: result
    else
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the invite
  end # end of update incite deadline

   @doc """
    Adds the deadline and the required number of collaborators
  """
  def update_invite_description(%User{} = user, %Invite{} = invite, description) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
      # update the order
      with {:ok, _invite} = result <- Collaborations.update_invite_description(invite, %{description: description}), do: result
    else
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the invite

  end # end of update incite deadline

  @doc """
    Adds payment information about an invite
  """
  def update_invite_payment(%User{} = user, %Invite{} = invite, payment_params) do
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
      # update the order
      with {:ok, _invite} = result <- Collaborations.update_invite_payment(invite, payment_params), do: result
    else
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the invite
  end # end of update invite information

  @doc """
    Creates a new order offer
  """
  def create_invite_offer(%User{} = user, %Invite{} = invite, asking_amount) do
    # preload work profile of the curent user
    user = Repo.preload(user, [:work_profile])
    # create invite offer
    offer = user
    # add the owner information
    |> Ecto.build_assoc(:invite_offers, %{
      # add invite id
      invite_id: invite.id,
      asking_amount: String.to_integer(asking_amount),
      owner_name: user.full_name,
      owner_rating: user.work_profile.rating,
      owner_about: user.work_profile.professional_intro,
      owner_job_success: user.work_profile.success_rate,
      owner_skills: user.work_profile.skills,
      owner_profile_pic: Utils.upload_url(Eworks.Uploaders.ProfilePicture.url({user.profile_pic, user}))
    })
    # create the offer
    |> Repo.insert!()

    # task for sending an email notification to the owner of the invite
    Task.start(fn ->
      # preload the owner of the order
      owner = Repo.preload(invite, [work_profile: [:user]]).work_profile.user
      # message
      message = "#{user.full_name} has submitted an offer of amount KES #{asking_amount} for your collaboration invite **#{invite.category} :: #{invite.specialty}**"
      # send an email notification to the owner of the order
      NewEmail.new_email_notification(owner, "Invite Offer Submission for Invite:  **#{invite.category} :: #{invite.specialty}**", "#{message} \n Login to your account for more details.")
      # send the email
      |> Mailer.deliver_later()

      # create a notification for the owner of the invite
      # create the notification
      {:ok, notification} = Notifications.create_notification(%{
        user_id: owner.id,
        asset_type: "Invite Offer",
        asset_id: invite.id,
        notification_type: "Invite Offer Submission",
        message: message
      })
      # send the notification to the user through a websocket.
      Endpoint.broadcast!("notification:#{owner.id}", "new_notification", %{notification: notification})
    end)
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
            notification_type: "Collaboration Invite Offer Rejection",
            message: "#{user.full_name} has rejected your collaboration offer of amount KES #{offer.asking_amount} request for **invite.category :: #{invite.specialty}**"
          })
          # send the notification
          Endpoint.broadcast!("user:#{offer.user_id}", "new_notification", %{notification: notification})
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
  def accept_invite_offer(_user, %Invite{required_collaborators: collaborators}, _offer_id) when collaborators + 1 > collaborators, do: {:error, :already_assigned}
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
        with _offer <- offer |> Ecto.Changeset.change(%{is_accepted: true, is_pending: false}) |> Repo.update!() do
          # send a notification to the owner of the invite offer using websocket
          Task.start(fn ->
            # creare message for notification
            message = "#{user.full_name} has accepted your submitted collaboration offer of amount KES #{offer.asking_amount}. **#{invite.category} :: #{invite.specialty}**"
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
            Endpoint.broadcast!("user:#{offer_owner.id}", "new_notification", %{notification: notification})
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
    # preload the work profile
    profile = Repo.preload(user, [:work_profile]).work_profile
    # ensure the current user is the owner of the invite
    if profile.id == invite.work_profile_id do
       # cacnel the order
       with invite <- invite |> Ecto.Changeset.change(%{is_cancelled: true}) |> Repo.update!() do
        # task for notifying the users who have invite offers
        Task.start(fn ->
          # preload the offers
          offers = Repo.preload(invite, [collaboration_offers: from(offer in InviteOffer, where: offer.is_cancelled == false and offer.is_rejected == false)]).collaboration_offers
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
                  asset_type: "Invite Offer",
                  asset_id: offer.id,
                  notification_type: "Invite Offer Rejection",
                  message: "Your collaboration invite offer of amount KES #{offer.asking_amount} has been rejected because the collaboration request was cancelled by owner."
                })
                # send notification
                Endpoint.broadcast("user:#{offer.user_id}", "new_notification", %{notification: notification})
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

  @doc """
    Send invite collaboration invite
  """
  def send_verification_code(%User{} = user, %Invite{} = invite) do
    # send an email to the user with the verification order
    NewEmail.new_invite_verification_code_email(user, invite)
    # send the email
    |> Mailer.deliver_later()
    # return :ok
    :ok
  end # end of send verification code

  @doc """
    Resends a new verification code
  """
  def resend_verification_code(%User{} = user, %Invite{} = invite) do
    # set a new verification code and send it to the user
    with invite <- Ecto.Changeset.change(invite, %{verification_code: Enum.random(100_000..999_999)}) |> Repo.update!() do
      # send an email to the user with the verification order
      NewEmail.new_invite_verification_code_email(user, invite)
      # send the email
      |> Mailer.deliver_later()
      # return :ok
      :ok
    end
  end # end of send verification code

  @doc """
    verifies an invite
  """
  def verify_invite( _user, %Invite{} = invite, verification_code) do
    # check if the verification codes match
    if invite.verification_code == String.to_integer(verification_code) do
      # update the invite to not draft
      invite = invite
      # set the verificaiton code to nil and the is draft to false
      |> Ecto.Changeset.change(%{
        verification_code: nil,
        is_draft: false
      })
      # update the invite
      |> Repo.update!()

      # return ok
      {:ok, invite}

    else
        {:error, :invalid_code}
    end # end of if
  end # end of verify invite


  ############################## PRIVATE FUNCTIONS ######################
  defp upload_url(url) do
    if url, do: url |> String.split("?") |> List.first(), else: nil
  end

end # end of module
