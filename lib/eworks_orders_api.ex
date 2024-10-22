defmodule Eworks.Orders.API do
  @moduledoc """
    Defines api for Order and Order offers
  """
  import Ecto.Query, warn: false

  alias Eworks.Accounts
  alias Eworks.Accounts.{WorkProfile, User}
  alias Eworks.{Orders, Repo, Uploaders, Notifications}
  alias Eworks.Orders.{Order, OrderOffer}
  alias Eworks.Utils.{Mailer, NewEmail}
  alias EworksWeb.Endpoint

  @doc """
    Gets an order
  """
  def get_order(%User{} = user, %Order{} = order) do
    # ensure the current user is the owner
    if user.id == order.user_id do
      # preload the order offers
      order = Repo.preload(order, [order_offers: from(offer in OrderOffer, where: offer.is_rejected == false and offer.is_cancelled == false)])
      # for each of the offers preload their owners
      offers = Stream.map(order.order_offers, fn offer -> offer |> Repo.preload([user: [:work_profile]]) end) |> Enum.to_list()
      # return the result
      {:ok, %{order: order, offers: offers}}
    else
      {:error, :not_owner}
    end # end of if for checking if the current user is the owner of the job
  end # end of get_order
  @doc """
    Creates a new order
  """
  def create_new_order(%User{} = user, order_params) do
    user
    # add the user id to the order
    |> Ecto.build_assoc(:orders, %{owner_name: user.full_name})
    # create the order
    |> Orders.create_order(order_params)
  end # creates an new order

  @doc """
    Adds the payment information of the order
  """
  def update_order_payment(%User{} = user, %Order{} = order, payment_params) do
    # ensure the current user is the owner of the order
    if order.user_id == user.id do
      # update the order
      with {:ok, _order} = result <- Orders.update_order_payment(order, payment_params), do: result
    else
      # now owner
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the id
  end # end of the adding the payment information


  @doc """
    Updates the order's type and duration
  """
  def update_order_duration(%User{} = user, %Order{} = order, duration_params) do
    # ensure the current user is the owner of the order
    if order.user_id == user.id do
      # update the order
      with {:ok, _order} = result <- Orders.update_order_duration(order, duration_params), do: result
    else
      # now owner
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the id
  end # end of the update_order_type and duration


  @doc """
    Updates the order's type and required contractors
  """
  def update_order_type_and_contractors(%User{} = user, %Order{} = order, type_params) do
    # ensure the current user is the owner of the order
    if order.user_id == user.id do
      # update the order
      with {:ok, _order} = result <- Orders.update_order_type_and_contractors(order, type_params), do: result
    else
      # now owner
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the id
  end # end of the update_order_type and the number of required contractors

  @doc """
    Updates the order's type and required contractors
  """
  def update_order_category(%User{} = user, %Order{} = order, order_params) do
    # ensure the current user is the owner of the order
    if order.user_id == user.id do
      # update the order
      with {:ok, _order} = result <- Orders.update_order_category(order, order_params), do: result
    else
      # now owner
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the id
  end # end of the update_order_type and the number of required contractors


  @doc """
    Updates the order's description
  """
  def update_order_description(%User{} = user, %Order{} = order, description) do
    # ensure the current user is the owner of the order
    if order.user_id == user.id do
      # update the order
      with {:ok, _order} = result <- Orders.update_order_description(order, %{description: description}), do: result
    else
      # now owner
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the id
  end # end of the update order description

  @doc """
    Updates the attachments of a given order
  """
  def update_order_attachments(%User{} = user, %Order{} = order, attachments) do
    # check if the current user is the owner of the order
    if order.user_id == user.id do
      # upload the documents
      with {:ok, _order} = result <- Uploaders.OrderAttachment.upload_attachments(order, attachments), do: result
    else
      # the user is not the owner of the job
      {:error, :not_owner}
    end # end of if
  end # end of update_order_attachments/2


  @doc """
    Submits an offer
  """
  def submit_order_offer(%User{} = user, %Order{} = order, asking_amount) do
    # get all the ids of the users who have already made an offer fot this order
    offer_ids = Repo.preload(order, [order_offers: from(offer in OrderOffer, select: [offer.user_id])]).order_offers
    # ensure current user id is not in the offers
    if user.id not in offer_ids do
      # create a new order offer
      with offer <- user |> Ecto.build_assoc(:order_offers, %{order_id: order.id, asking_amount: asking_amount}) |> Repo.insert!() do
        # create a notification about the submitting of the offer
        Task.start(fn ->
          # preload the owner of the order
          owner = Accounts.get_user!(order.user_id)
          # message
          message = "#{user.full_name} has submitted an offer of KES #{asking_amount} to work of your order **#{order.category}::#{order.specialty}**."
          # send an email notification to the owner of the order
          NewEmail.new_email_notification(owner, "Offer submission for order: **#{order.category} :: #{order.specialty}**", "#{message} \n Login to your account for more details.")
          # send the email
          |> Mailer.deliver_later()

          # create a new notification
          {:ok, notification} = Notifications.create_notification(%{
            user_id: owner.id,
            asset_type: "Offer",
            asset_id: order.id,
            notification_type: "Order Offer Submission",
            message: message
          })
          # send the notification to the user using websocket
          Endpoint.broadcast!("notification:#{order.user_id}", "new_notification", %{notification: notification})
        end) # end of the task
        # return ok
        {:ok, offer}
      end # end of with creating an offer

    else
      # user has already submitted the offer
      {:error, :already_submitted}
    end # end of of checking if the user.id is in the offer ids
  end # end of submitting an order offer


  @doc """
    Function that accepts an order
  """
  def accept_order_offer(%User{} = _user, %Order{required_contractors: contractors, accepted_offers: offers}, _offer_id) when contractors *3 == offers + 1, do: {:error, :max_offers_reached}
  def accept_order_offer(%User{} = user, %Order{} = order, offer_id) do
    # check if the current user is the owner of the job
    if order.user_id == user.id do
      # get the order offer
      [offer | _rest] = Repo.preload(order, [order_offers: from(offer in OrderOffer, where: offer.id == ^offer_id)]).order_offers
      # update the offer
      case accept_offer(offer, user.full_name, order.specialty, order.category) do
        # offer successfully accepted
        :ok ->
          # check if the order has already allowed number of offers allowed to accept
          updated_order = if (order.accepted_offers + 1) == (order.required_contractors * 3) do
            # update the order
                order
                # add the number of accepted offers by one
                |> Ecto.Changeset.change(%{
                  accepted_offers: order.accepted_offers + 1
                })
                # update the order
                |> Repo.update!()
                # get the bid for which the user has accepted
                |> Repo.preload([
                  order_offers: from(
                    offer in OrderOffer,
                    # make sure the offer is is not cancelled and not rejected
                    where: offer.is_accepted == true,
                   # get the owner of the offer
                   join: owner in assoc(offer, :user),
                   # preload the work profile of the user
                   join: profile in assoc(owner, :work_profile),
                   # preload the user
                   preload: [user: {owner, work_profile: profile}]
                  )
                ])
          else
            # the user still can accept other offers
                order
                # reduce the number of required contractors
                |> Ecto.Changeset.change(%{
                  accepted_offers: order.accepted_offers + 1
                })
                # update the order
                |> Repo.update!()
                # preload all the offers
                |> Repo.preload([
                  order_offers: from(
                    offer in OrderOffer,
                    # make sure the offer is is not cancelled and not rejected
                    where: offer.is_cancelled == false and offer.is_rejected == false,
                   # get the owner of the offer
                   join: owner in assoc(offer, :user),
                   # preload the work profile of the user
                   join: profile in assoc(owner, :work_profile),
                   # preload the user
                   preload: [user: {owner, work_profile: profile}]
                  )
                ])
          end # end of if for checking if the user can make more offers

          # return the order
          {:ok, updated_order}

        # offer not accepted
        _ ->
          # return the result
          {:error, :offer_cancelled}
      end # end of case for accepting the offer
    else
      # not user
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the order
  end # end of accept_order_offer


  @doc """
    Function for assigning an order
  """
  def assign_order(%User{} = user, %Order{} = order, to_assign_id) do
    # get the work profile of the person being assigned the job
    profile = from(
      profile in WorkProfile,
      # ensure the id matches that user to be assigned
      where: profile.user_id == ^to_assign_id,
      # join the user
      join: user in assoc(profile, :user),
      # preload the user
      preload: [user: user]
    )
    # get the user
    |> Repo.one!()

    # check if the job has already been assigned or the number of already assigned orders matches the number of required contractors
    if not order.is_assigned or order.already_assigned != order.required_contractors do
      # chek if the one be assigned is not suspeded
      if not profile.user.is_suspended do # the person being assigned the order has not being suspended
        # assign the job
        with _assigned_order <- profile |> Ecto.Changeset.change(%{assigned_orders: [order.id | profile.assigned_orders]}) |> Repo.update!() do
          # start a task for sending the assignee a notification about the assigning
          Task.start(fn ->
            # message
            message = "#{user.full_name} has assigned you to work on their order: **#{order.category} :: #{order.specialty}**."
            # send an email notification to the owner of the order
            NewEmail.new_email_notification(profile.user, "Order Assignment for order: **#{order.category} :: #{order.specialty}**", "#{message} \n Login to your account for more details.")
            # send the email
            |> Mailer.deliver_later()

            # create a notification about being assigned the job
            {:ok, notification} = Notifications.create_notification(%{
              user_id: to_assign_id,
              asset_type: "Order",
              asset_id: order.id,
              notification_type: "Order Assignmenr",
              message: message
            })
            # notify the assigned user through the websocket using the notification::new_assigned_order
            Endpoint.broadcast!("notification:#{to_assign_id}", "new_notification", %{notification: notification})
          end) # end of task for sending a notification to the user about the job assignment

          # check if once the added assignee is added, it brings the number of assigned equal to the required orders
          if order.required_contractors == order.already_assigned + 1 do
            # update the order
            order
            # increase the number of assigned by one and set the assigned to true
            |> Ecto.Changeset.change(%{already_assigned: order.already_assigned + 1,
              is_assigned: true,
              assignees: [to_assign_id | order.assignees]
            })
            # update the offer
            |> Repo.update!()

          else # the number of already assigned is not yet equals to the number of required contractractors
            # update the order
            order
            # increase the number of assigned by one
            |> Ecto.Changeset.change(%{
              already_assigned: order.already_assigned + 1,
              assignees: [to_assign_id | order.assignees]
            })
            # update the offer
            |> Repo.update!()
          end # end of checking if the number of already assigned equals that of the required contractors

          # return the result
          {:ok, profile.user.full_name}

        end # end of the assigning the work

      else # the user is suspended
        # retun error indicating the user is suspended
        {:error, :user_suspended, profile.user.full_name}
      end # end of checking if the assignee is suspended or not

    else
      # the order has already being assigned
      {:error, :already_assigned}
    end # end of checking whether the order has already been assigned or the required contractors have been met

  rescue
    # the result not found
    Ecto.NoResultsError ->
      # return an error
      {:error, :prof_not_found}
  end # end of assigning an order

  @doc """
    Function for rejecting an offer
  """
  def reject_order_offer(%User{} = user, %Order{} = order, offer_id) do
    # ensure the current user is the owner of the order
    if order.user_id == user.id do
      # create a tak to reject the offer
      Task.start(fn ->
        # get the order_offer with the given id
        [offer | _rest] = Repo.preload(order, [order_offers: from(offer in OrderOffer, where: offer.id == ^offer_id)]).order_offers
        # only reject the bid if the oofer has not being cancelled
        with false <- offer.is_cancelled, updated_offer <- offer |> Ecto.Changeset.change(%{is_pending: false, is_rejected: true}) |> Repo.update!() do
          # creaate a notification to informat the owner of the offer about the rejection.
          {:ok, notification} = Notifications.create_notification(%{
            user_id: updated_offer.user_id,
            asset_type: "Order Offer",
            asset_id: offer_id,
            notification_type: "Order Offer Rejection",
            message: "#{user.full_name} has rejected your submitted offer of amount KES #{offer.asking_amount} for order **#{order.category} :: #{order.specialty}**."
          })
          # send notification to the owner of the offer through the websocket
          Endpoint.broadcast!("notification:#{updated_offer.user_id}", "new_notification", %{notification: notification})
        end # end of the with
      end) # end of with for checking the order had being cancelled.
      # return ok
      :ok
    else
      {:error, :not_owner}
    end # end of checking if the current user is the owner of the order
  end # end of reject_order_order/1

  @doc """
    Cancels an offer
  """
  def cancel_order_offer(offer_id) do
    with offer <- Orders.get_order_offer!(offer_id) do
      # ensure the offer is strill pending
      if offer.is_pending do
        # reject the offer
        offer = offer |> Ecto.Changeset.change(%{is_pending: false, is_cancelled: true}) |> Repo.update!()
        # start a task to delete the offer
        Task.start(fn -> Orders.delete_order(offer) end)
        # return ok
        :ok

      else
        # the offer has been accepted
        {:error, :already_accepted}
      end # end of if
    end # end of getting the offer
  end # end of cancel_order_offer/1

  @doc """
    Accepts an request from order owner to work on their order
  """
  def accept_order(%User{} = user, %Order{} = order, order_offer_id) do
    # get the order_offer
    #order_offer = Orders.get_order_offer!(order_offer_id)
    [order_offer | _rest] = Repo.preload(order, [order_offers: from(offer in OrderOffer, where: offer.id == ^order_offer_id)]).order_offers
    # ensure that the current user if the owner of the offer
    if order_offer.user_id == user.id do
      # update the offer to set the accepted_order to true
      with offer <- Ecto.Changeset.change(order_offer, %{has_accepted_order: true}) |> Repo.update!() do
        # # create a notification for the owner of the order about the accepting of the order
        Task.start(fn ->
          # preload the owner of the order
          owner = Repo.preload(order, [:user]).user
          # message
          message = "#{user.full_name} has acepted to be contracted to work on your order: **#{order.category} :: #{order.specialty}**"
          # send an email notification to the owner of the order
          NewEmail.new_email_notification(owner, "Order Acceptance for Order:  **#{order.category} :: #{order.specialty}**", "#{message} \n Login to your account for more details.")
          # send the email
          |> Mailer.deliver_later()

          # create the notification
          {:ok, notification} = Notifications.create_notification(%{
            user_id: order.user_id,
            asset_type: "Order",
            asset_id: order.id,
            notification_type: "Order Acceptance",
            message: message
          })
          # send the notification to the user through a websocket.
          Endpoint.broadcast!("notification:#{order.user_id}", "new_notification", %{notification: notification})
        end) # end of task
        # return the order
        {:ok, offer}
      end # end of with updating the update
    else
      # user not owner
      {:error, :not_owner}
    end # end of checking whether the current user is teh owner of the offer
  end

  @doc """
    Reject order
  """
  def reject_order(%User{} = user, %Order{} = order, offer_id) do
    # get the order_offer
    #order_offer = Orders.get_order_offer!(order_offer_id)
    [order_offer | _rest] = Repo.preload(order, [order_offers: from(offer in OrderOffer, where: offer.id == ^offer_id)]).order_offers
    # ensure that the current user if the owner of the offer
    if order_offer.user_id == user.id do
      # update the offer to set the rejected_order to true
      with offer <- Ecto.Changeset.change(order_offer, %{has_rejected_order: true, order_accepting_pending: false}) |> Repo.update!() do
        # # create a notification for the owner of the order about the accepting of the order
        Task.start(fn ->
          # preload the owner of the order
          owner = Repo.preload(order, [:user]).user
          # message
          message = "#{user.full_name} has declined to be contracted to work on your order **#{order.category} :: #{order.specialty}**"
          # send an email notification to the owner of the order
          NewEmail.new_email_notification(owner, "Order Decline for order: **#{order.category} :: #{order.specialty}**", "#{message} \n Login to your account for more details.")
          # send the email
          |> Mailer.deliver_later()

          # create the notification
          {:ok, notification} = Notifications.create_notification(%{
            user_id: order.user_id,
            asset_type: " Order",
            asset_id: order.id,
            notification_type: "Order Rejection",
            message: message
          })
          # send the notification to the user through a websocket.
          Endpoint.broadcast!("notification:#{order.user_id}", "new_notification", %{notification: notification})
        end) # end of task
        # return the order
        {:ok, offer}
      end # end of with updating the update
    else
      # user not owner
      {:error, :not_owner}
    end # end of checking whether the current user is teh owner of the offer
  end

  @doc """
    Sends a verification code for a given order
  """
  def send_order_verification_code(%User{} = user, %Order{} = order) do
    # ensure the user is the owner of the order
    if user.id == order.user_id do
      # send an email to the user with the verification order
      NewEmail.new_order_verification_code_email(user, order)
      # send the email
      |> Mailer.deliver_later()
      # return :ok
      :ok
    else
      # not owner
      {:error, :not_owner}
    end # end of checking whether the current user is the owner order
  end # end of sending order verification code

  @doc """
    Sends a verification code for a given order
  """
  def resend_order_verification_code(%User{} = user, %Order{} = order) do
    # ensure the user is the owner of the order
    if user.id == order.user_id do
      # update the order to enter this as the new verification key
      order = order
      # put the new verification code
      |> Ecto.Changeset.change(%{
        verification_code: Enum.random(100000..999999)
      })
      # update order
      |> Repo.update!()

      # send an email to the user with the verification order
      NewEmail.new_order_verification_code_email(user, order)
      # send the email
      |> Mailer.deliver_later()
      # return :ok
      :ok
    else
      # not owner
      {:error, :not_owner}
    end # end of checking whether the current user is the owner order
  end # end of sending order verification code

  @doc """
    Tags an order
  """
  def tag_order(%User{} = user, %Order{} = order) do
    # ensure the order has not being assigned
    if order.is_assigned do
      # return error
      {:error, :already_assigned}
    else
      # place the tag to the order
      order = order |> Ecto.Changeset.change(%{tags: [user.id | order.tags]}) |> Repo.insert!()
      # return the order
      {:ok, order}
    end # end of is assigned
  end # end of tag order

  @doc """
    Vrifies an order
  """
  def verify_order(%User{} = user, %Order{} = order, verification_code) do
    # ensure the user is the owner of the job
    if order.user_id == user.id do
      # check if the verification code is similar
      if order.verification_code == String.to_integer(verification_code) do
        # update the order
        with {:ok, _order} = result <- order |> Ecto.Changeset.change(%{is_verified: true, is_draft: false, verification_code: nil}) |> Repo.update(), do: result
      else
        # not similar
        {:error, :invalid_verification_code}
      end # end of if for checking if the verification code is similar
    else
      # the current user is not the owner
      {:error, :not_owner}
    end # end of if
  end # end of the

  @doc """
    Cancel order
  """
  def cancel_order(%User{} = user, %Order{} = order) do
    # ensure the user is the owner of order
    if user.id == order.user_id do
      # preload the orders that have not being rejected
      order = Repo.preload(order, [
        # preload the direct hire
        :direct_hire,
        # preload the order offers
        order_offers: from(
          offer in OrderOffer,
          # ensure the offer is not cancelled and has not being rejected
          where: offer.is_rejected == false and offer.is_cancelled == false
        )
      ])

      # update the offer to cancelled
      with order <- Ecto.Changeset.change(order, %{is_cancelled: true}) |> Repo.update!() do
        # send notifications to the owners of the offers
        Task.start(fn ->
          # check if the order has a direct hire request and also cancel the request
          with false <- is_nil(order.direct_hire), do: Eworks.Requests.API.cancel_direct_hire_request(user, order.direct_hire.id)
          # for each of the offers notify owner
          Stream.each(order.offers, fn offer ->
            # create a new notification
            {:ok, notification} = Notifications.create_notification(%{
              user_id: offer.user_id,
              asset_type: "Order Offer",
              asset_id: offer.id,
              notification_type: "Offer Rejection",
              message: "Your order offer for amount #{offer.asking_amount} for the order: **#{order.category} :: #{order.specialty}** has been rejected due to cancellation of the order."
            })

            # send the notificaiton
            Endpoint.broadcast!("notification:#{offer.user_id}", "new_notification", %{notification: notification})
          end)
          # run the stream
          |> Stream.run()
        end) # end of task

        # return the result
        {:ok, order}
      end # end of wih for updating the order
    else
      # return not owner
      {:error, :not_owner}
    end
  end # end of cancel orders

  @doc """
    Marks an order as completed
  """
  def mark_order_complete(%User{} = user, %Order{} = order) do
    # mark the order as complete
    with order <- Ecto.Changeset.change(order, %{is_complete: true}) |> Repo.update!() do
      # send the owner of the order a notification
      Task.start(fn ->
        # send an email notification to the order owner
        owner = Repo.preload(order, [:user]).user
        # message
        message = "#{user.full_name} has completed working on your order *#{order.category} :: #{order.specialty}**. Please review the order and approve the contractor's payment."
        # send an email notification to the owner of the order
        NewEmail.new_email_notification(owner, "Order Completion for order: **#{order.category} :: #{order.specialty}**", "#{message} \n Login to your account for more details.")
        # send the email
        |> Mailer.deliver_later()

        # create the notification
        {:ok, notification} = Notifications.create_notification(%{
          user_id: order.user_id,
          asset_type: "Order",
          asset_id: order.id,
          notification_type: "Order Completion",
          message: message
        })

        # send the notification to the user
        Endpoint.broadcast!("notification:#{owner.id}", "new_notification", %{notification: notification})
      end) # end of task

      # return the result
      {:ok, order}
    end # end of with
  end # end of mark order

  @doc """
    approve payment for the given user
  """
  def approve_payment(%User{} = _user, %Order{} = order, contractor_id, contractor_rating, comment) do
    # get the invite that belongs to the given user
    offer = from(
      offer in OrderOffer,
      # ensure the offer belongs to the contractor and is for the specified invite
      where: offer.user_id == ^contractor_id and offer.order_id == ^order.id,
      # get the user for which the offer belongs to
      join: user in assoc(offer, :user),
      # get the workprofile of the user as weel
      join: profile in assoc(user, :work_profile),
      # preload teh user
      preload: [user: {user, work_profile: profile}]
    )
    # get the offer
    |> Repo.one!()

    # initiate the payment for the user
    with :ok <- Eworks.Payment.API.pay_contractor(%{phone: offer.user.phone, amount: offer.asking_amount}) do
      # start a task that will update the contractors rating
      Task.start(fn ->
        # update the user's average rating
        new_rating = new_contractor_rating(offer.user, contractor_rating)
        # update the work profile of the contractor
        Ecto.Changeset.change(offer.user.work_profile, %{
          rating: new_rating,
          # add the order id to the list of previous hires
          previous_hires: [order.id | offer.user.work_profile.previous_hires]
        })
        # update the profile
        |> Repo.update!()
      end)
      # add the current contractor id to the paid contractors
      Ecto.Changeset.change(order, %{
        paid_assignees: [contractor_id | order.paid_assignees]
      })
      # update the
      |> Repo.update!()
      # create a new review
      |> Ecto.build_assoc(:reviews)
      # build a changeset
      |> Eworks.Reviews.Review.changeset(%{
        user_id: contractor_id,
        comment: comment,
        rating: contractor_rating
      })
      # create the new review
      |> Repo.insert!()
      # create a transaction for this payment for the current user
      # return ok
      :ok
    end
  end # end of approve payment

  ####################################### PRIVATE FUNCTIONS #########################################

  defp accept_offer(offer, order_owner_name, order_specialty, order_category) do
    # check if the offer is cancelled or not
    if not offer.is_cancelled do
      # update the offer
      with offer <- offer |> Ecto.Changeset.change(%{is_accepted: true, is_pending: false}) |> Repo.update!() do
        # start task to create a notification for offer acceptance
        Task.start(fn ->
          # get the owner
          owner = Repo.preload(offer, [:user]).user
          # message
          message = "#{order_owner_name} has accepted the offer of amount KES #{offer.asking_amount} you submitted to work on their order **#{order_category} :: #{order_specialty}**"
          # send an email notification to the owner of the order
          NewEmail.new_email_notification(owner, "Offer Acceptance for order: **#{order_category} :: #{order_specialty}**", "#{message} \n Login to your account for more details.")
          # send the email
          |> Mailer.deliver_later()

          {:ok, notification} = Notifications.create_notification(%{
            user_id: offer.user_id,
            asset_type: "Offer",
            asset_id: offer.id,
            notification_type: "Offer Acceptance",
            message: message
          })
          # send the noification to the user through the webscoket
          Endpoint.broadcast!("notification:#{offer.user_id}", "new_notification", %{notification: notification})
        end) # end of task

        # return ok
        :ok
      end # end of updating a new order
    else
      # offer is cancelled
      {:error, :offer_cancelled}
    end # end of the checking if the offer has being cancelled
  end

  # function for calcultaing the contractor's new rating
  defp new_contractor_rating(%User{work_profile: %WorkProfile{previous_hires: hires, rating: current_rating}}, new_rating), do: (current_rating + new_rating) / (Enum.count(hires) + 1)

end # end of the api module for orders and order offers
