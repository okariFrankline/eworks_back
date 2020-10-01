defmodule Eworks.Orders.API do
  @moduledoc """
    Defines api for Order and Order offers
  """
  import Ecto.Query, warn: false

  alias Eworks.Accounts.{WorkProfile, User}
  alias Eworks.{Orders, Repo, Accounts, Uploaders, Notifications}
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
    # create a new order user from the current user
    order_owner = Orders.order_user_from_account_user(user)
    # create a new order
    order = order_owner
    # add the user id to the order
    |> Ecto.build_assoc(:orders)
    # create the order
    |> Orders.create_order(order_params)

    IO.inspect(order)
    order
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
    # create a new order offer
    with _offer <- user |> Ecto.build_assoc(:order_offers, %{order_id: order.id, asking_amount: asking_amount}) |> Repo.insert!() do
      # update the order to add the
      # create a notification about the submitting of the offer
      Task.start(fn ->
        {:ok, notification} = Notifications.create_notification(%{
          user_id: order.user_id,
          asset_type: :offer,
          notification_type: :order_offer_submission,
          message: "#{user.full_name} has submitted an offer for your order looking for #{order.specialty}."
        })
        # send the notification to the user using websocket
        Endpoint.broadcast!("notification:#{order.user_id}", "notification::offer_submission", %{notification: notification})
      end) # end of the task
      # return ok
      :ok
    end # end of with creating an offer
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
      case accept_offer(offer, user.full_name, order.specialty) do
        # offer successfully accepted
        :ok ->
          # check if the order has already allowed number of offers allowed to accept
          if (order.accepted_offers + 1) == (order.required_contractors * 3) do
            # update the order
            updated_order = order
                # add the number of accepted offers by one
                |> Ecto.Changeset.change(%{
                  accepted_offers: order.accepted_offers + 1
                })
                # update the order
                |> Repo.update!()
                # get the bid for which the user has accepted
                |> Repo.preload([order_offers: from(offer in OrderOffer, where: offer.is_accepted == true)])

            # preload the owner of each of the offers
            offers = Enum.map(updated_order.order_offers, fn offer -> Repo.preload(offer, [user: [:work_profile]]) end)

            # return the updated offer, the owner of the offer and the offers
            {:ok, %{order: updated_order, offers: offers}}
          else
            # the user still can accept other offers
            updated_order = order
                # reduce the number of required contractors
                |> Ecto.Changeset.change(%{
                  accepted_offers: order.accepted_offers + 1
                })
                # update the order
                |> Repo.update!()
                # preload all the offers
                |> Repo.preload([order_offers: from(offer in OrderOffer, where: offer.is_rejected == false and offer.is_cancelled == false)])

            # preload the owner of the offers for each of the offers
            offers = Stream.map(updated_order.order_offers, fn offer -> Repo.preload(offer, [user: [:work_profile]]) end) |> Enum.to_list()

            # return the updated offer, the owner of the offer and the offers
            {:ok, %{order: updated_order, offers: offers}}
          end # end of if for checking if the user can make more offers

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
    profile = from(profile in WorkProfile, where: profile.user_id == ^to_assign_id) |> Repo.one!() |> Repo.preload(:user)
    # check if the job has already been assigned or the number of already assigned orders matches the number of required contractors
    if not order.is_assigned and order.already_assigned != order.required_contractors do
      # chek if the one be assigned is not suspeded
      if not profile.user.is_suspended do # the person being assigned the order has not being suspended
        # assign the job
        with _assigned_order <- profile |> Ecto.Changeset.change(%{assigned_orders: [order.id | profile.assigned_orders]}) |> Repo.update!() do
          # start a task for sending the assignee a notification about the assigning
          Task.start(fn ->
            # create a notification about being assigned the job
            {:ok, notification} = Notifications.create_notification(%{
              user_id: to_assign_id,
              asset_type: :order,
              asset_id: order.id,
              notification_type: :order_assignment,
              message: "#{user.full_name} has assigned you the order looking for #{order.specialty}."
            })
            # notify the assigned user through the websocket using the notification::new_assigned_order
            Endpoint.broadcast!("notification:#{to_assign_id}", "notification::new_assigned_order", %{notification: notification})
          end) # end of task for sending a notification to the user about the job assignment

          # check if once the added assignee is added, it brings the number of assigned equal to the required orders
          updated_order = if order.required_contractors == order.already_assigned + 1 do
            # update the order
            order
            # increase the number of assigned by one and set the assigned to true
            |> Ecto.Changeset.change(%{already_assigned: order.already_assigned + 1,
              is_assigned: true,
              assignees: [to_assign_id | order.assignees]
            })
            # update the offer
            |> Repo.update!()
            # preload the assignees and the order offers
            |> Repo.preload(order_offers: from(offer in OrderOffer, where: offer.is_accepted == true))

          else # the number of already assigned is not yet equals to the number of required contractractors
            # update the order
            order
            # increase the number of assigned by one
            |> Ecto.Changeset.change(%{already_assigned: order.already_assigned + 1,
              assignees: [to_assign_id | order.assignees]
            })
            # update the offer
            |> Repo.update!()
            # preload the assignees and the order offers
            |> Repo.preload(order_offers: from(offer in OrderOffer, where: offer.is_accepted == true))
          end # end of checking if the number of already assigned equals that of the required contractors

          # for each of the offers prload their owners
          offers = Enum.map(updated_order.order_offers, fn offer -> offer |> Repo.preload([user: [:work_profile]]) end)

          # return the result
          {:ok, %{order: updated_order, offers: offers}}

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
            asset: :offer,
            asset_id: offer_id,
            notification_type: :order_offer_rejection,
            message: "#{user.full_name} has rejected your offer for order lookign for #{order.specialty}."
          })
          # send notification to the owner of the offer through the websocket
          Endpoint.broadcast!("notification:#{updated_offer.user_id}", "notification::offer_rejected", %{notification: notification})
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
    # start a task to cancel the offer
    Task.start(fn ->
      # get the offer
      offer = Repo.get!(OrderOffer, offer_id)
      # cancel the offer only if the order's status is in pending
      with true <- offer.is_pending do
        offer
        # set the is-penidng to false and the is_cancelled to true
        |> Ecto.Changeset.change(%{
          is_pending: false,
          is_cancelled: true
        })
        # update the offer
        |> Repo.update!()
      end # end of with
    end)
    # return ok
    :ok
  end # end of cancel_order_offer/1

  @doc """
    Accepts an request from order owner to work on their order
  """
  def accept_order(%User{} = user, %Order{} = order, order_offer_id) do
    # get the order_offer
    [order_offer | _rest] = Repo.preload(order, [order_offers: from(offer in OrderOffer, where: offer.id == ^order_offer_id)]).order_offers
    # ensure that the current user if the owner of the offer
    if order_offer.user_id == user.id do
      # update the offer to set the accepted_order to true
      with offer <- Ecto.Changeset.change(order_offer, %{has_accepted_order: true}) |> Repo.update!() do
        # # create a notification for the owner of the order about the accepting of the order
        Task.start(fn ->
          # create the notification
          {:ok, notification} = Notifications.create_notification(%{
            user_id: order.user_id,
            asset_type: :offer,
            asset_id: order_offer_id,
            notification_type: :order_acceptance,
            message: "#{user.full_name} has accepted to be to work on your order looking for #{order.specialty}."
          })
          # send the notification to the user through a websocket.
          Endpoint.broadcast!("notification:#{order.user_id}", "notification::order_acceptance", %{notification: notification})
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
      if order.verification_code == verification_code do
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

  ####################################### PRIVATE FUNCTIONS #########################################

  defp accept_offer(offer, order_owner_name, order_specialty) do
    # check if the offer is cancelled or not
    if not offer.is_cancelled do
      # update the offer
      with offer <- offer |> Ecto.Changeset.change(%{is_accepted: true, is_pending: false}) |> Repo.update!() do
        # start task to create a notification for offer acceptance
        Task.start(fn ->
          {:ok, notification} = Notifications.create_notification(%{
            user_id: offer.user_id,
            asset_type: :offer,
            asset_id: offer.id,
            message: "#{order_owner_name} has accepted your offer to work on his/her order looking for #{order_specialty}."
          })
          # send the noification to the user through the webscoket
          Endpoint.broadcast!("notification:#{offer.user_id}", "notification::offer_accepted", %{notification: notification})
        end) # end of task

        # return ok
        :ok
      end # end of updating a new order
    else
      # offer is cancelled
      {:error, :offer_cancelled}
    end # end of the checking if the offer has being cancelled
  end

end # end of the api module for orders and order offers
