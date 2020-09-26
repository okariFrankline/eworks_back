defmodule Eworks.Orders.API do
  @moduledoc """
    Defines api for Order and Order offers
  """
  alias Eworks.Accounts.User
  alias Eworks.Accounts.{WorkProfile}
  alias Eworks.{Orders, Repo, Accounts, Uploaders}
  alias Eworks.Orders.{Order, OrderOffer}
  alias Eworks.Utils.{Mailer, NewEmail}
  import Ecto.Query, warn: false
  @doc """
    Creates a new order
  """
  def create_new_order(%User{} = user, order_params) do
    # create a new order user from the current user
    order_owner = Orders.order_user_from_account_user(user)
    # create a new order
    order_owner
    # add the user id to the order
    |> Ecto.build_assoc(:orders)
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
    # create a new order
    user
    # add the user id and the order id
    |> Ecto.build_assoc(:order_offers, %{order_id: order_id, asking_amount: asking_amount})
    # create the offer
    |> Repo.insert!()
  end # end of submitting an order offer


  @doc """
    Function that accepts an order
  """
  def accept_order_offer(%User{} = user, %Order{} = order, order_offer_id) do
    # start the task for getting the offer
    offer_task = Task.async(fn ->
      Orders.get_order_offer!(order_offer_id)
    end)

    # check if the current user is the owner of the job
    if order.user_id == user.id do
      # update the offer
      case accept_offer(Task.await(offer_task)) do
        # offer successfully accepted
        :ok ->
          # update the order by reducing the number of required offers by 1 and return the order
          if order.accepted_offers + 1 == 3 do
            # update the order
            updated_order = order
                  # reduce the number of required contractors
                  |> Ecto.Changeset.change(%{
                    accepted_offers: order.accepted_offers + 1
                  })
                  # update the order
                  |> Repo.update!()
                  # get the bid for which the user has accepted
                  |> Repo.preload([order_offers: from(offer in OrderOffer, where: offer.is_accepted == true)])

            # preload all the offers
            {:ok, updated_order}
          else
            # the user still can accept other offers
            updated_order = order
                            # reduce the number of required contractors
                            |> Ecto.Changeset.change(%{
                              accepted_offers: order.accepted_offers + 1
                            })
                            # update the order
                            |> Repo.update!()
                            # preload the already accepted offers
                            |> Repo.preload([order_offers: from(offer in OrderOffer, where: offer.is_accepted == true)])

            # preload all the offers
            {:ok, updated_offer}
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
  def assign_order(%User{} = _user, order_id, to_assign_id) do
    # get the person to be assigned
    to_assignee_task = Task.async(fn -> Accounts.get_user!(to_assign_id) end)

    # get the order
    order = Orders.get_order!(order_id)
    # check if the job has being assigned
    if not order.is_assigned and order.already_assigned != order.required_contractors do
      # assign the job
      with _user <- Task.await(to_assignee_task) |> Ecto.Changeset.change(%{order_id: order_id}) |> Repo.update!() do
        # start a task for sending the assignee a notification about the assigning
        # updated order
        updated_order =  order
        # set the already assigned by adding one and required contractors by removing one
        |> Ecto.Changeset.change(%{
          already_assigned: order.already_assigned + 1,
          required_contractors: order.required_contractors - 1
        })
        # update the order
        |> Repo.update!()
        # preload the assigned practise
        |> Repo.preload(:assignees)

        # for each of the assignees preload the work profile and the order offers
        assignees = Enum.map(updated_order.assignees, fn assignee ->
          assignee
          # create the account user from the order
          |> Orders.account_user_from_order_user()
          # preload the workprofile and the order offers
          |> Repo.preload([
            # preload the work profile and return the full name and the professional intro
            work_profile: from(profile in WorkProfile, select: [profile.rating, profile.professional_intro]),
            # preload the order offer made for this particular offer
            order_offers: from(offer in OrderOffer, where: offer.order_id == ^order_id, select: [offer.asking_amount])
          ])
        end)

        # return the result
        {:ok, %{
          order: updated_order,
          assignees: assignees
        }}
      end # end of the assigning the work

    else
      # the order has already being assigned
      {:error, :already_assigned}
    end # end of checking whether the order has already been assigned or the required contractors have been met

  end # end of assigning an order


  @doc """
    Creates a new offer for a given order
  """
  def create_offer(%User{} = user, order_id, offer_params) do
    # create an association with the user
    user
    # add the user id to the params
    |> Ecto.build_assoc(:order_offers, Map.put(offer_params, :order_id, order_id))
    # create a new offer
    |> Repo.insert!()
  end # end of create offer

  @doc """
    Function for rejecting an offer
  """
  def reject_order_offer(offer_id) do
    # create a tak to reject the offer
    Task.start(fn ->
      # get the order_offer with the given id
      offer = Repo.get!(OrderOffer, offer_id)
      # only reject the bid if the oofer has not being cancelled
      with false <- offer.is_cancelled do
        # update the offer
        offer
        # set the is_pending to false and the is_rejected to true
        |> Ecto.Changeset.change(%{
          is_pending: false,
          is_rejected: true
        })
        # update the offer
        |> Repo.update!()
      end # end of the with
    end)
    # return ok
    :ok
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
  def accept_order(%User{} = user, order_offer_id) do
    # get the order_offer
    order_offer = Orders.get_order_offer!(order_offer_id)
    # ensure that the current user if the owner of the offer
    if order_offer.user_id == user.id do
      # update the offer to set the accepted_order to true
      with offer <- Ecto.Changeset.change(order_offer, %{accepted_order: true}) |> Repo.update!() |> Repo.preload([order: from(order in Order, select: [order.id, order.user_id, order.desription])]) do
        # get the order for which the offer is for
        Task.start(fn ->
          # get the order
          offer.order
          # order = Repo.one!(from order in Order, where: order.id == ^offer.order_id, select: [order.id])
          # notify the owner of the order of the accepting of the order
        end)
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
  def send_order_verification_code(%User{} = user, order_id) do
    # get the order
    order = Orders.get_order!(order_id)
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
    Vrifies an order
  """
  def verify_order(%User{} = user, order_id, verification_code) do
    # get the order
    order = Orders.get_order!(order_id)
    # ensure the user is the owner of the job
    if order.user_id == user.id do
      # check if the verification code is similar
      if order.verification_code == verification_code do
        # update the order
        with {:ok, order} = result <- order |> Ecto.Changeset.change(%{is_verified: true, is_draft: false, verification_code: nil}) |> Repo.update() do
          # return the result
          result
        end # end of with
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

  defp accept_offer(offer) do
    # check if the offer is cancelled or not
    if not offer.is_cancelled do
      # update the offer
      offer
      # put the is_accepted to true and set the is_pending to false
      |> Ecto.Changeset.change(%{
        is_accepted: true,
        is_pending: false
      })
      # update the offer
      |> Repo.update!()

      # send a notification to the owner of the the offer about the accepting of the offer
      :ok
    else
      # offer is cancelled
      {:error, :offer_cancelled}
    end # end of the checking if the offer has being cancelled
  end

end # end of the api module for orders and order offers
