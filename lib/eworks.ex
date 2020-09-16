defmodule Eworks do
  @moduledoc """
  Eworks keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Eworks.{Accounts, Profiles}
  alias Eworks.Repo
  alias Eworks.Accounts.{User}
  alias Eworks.Profiles.UserProfile
  import Ecto.Query, warn: false

  # function for checking whether a user with
  # a given auth_email exist
  defp user_exists?(auth_email) do
    from(
      user in User,
      where: user.auth_email == ^auth_email
    )
    # check if the user exists
    |> Repo.exists?()
  end # end of checking the email address

  @doc """
    Creates a user account and also the profile for the account
  """
  def register_user(:client, params) do
    # check if the user exists
    if user_exists?(params["auth_email"]) do
      # create the user
      with {:ok, user} <- Accounts.create_user(params) do
        # ceate a new profile user from the account user
        profile_user = Profiles.profile_user_from_account_user(user)

        # create a profile account for the user only after the user has being successfully created.
        Ecto.build_assoc(profile_user, :user_profile, %{emails: [user.auth_email]})
        # save the profile
        |> Repo.insert!()
        # return the user
        {:ok, user}
      end

    else
      # the user does exist
      {:error, :email_exists, %{message: "Failed. The email address #{params["auth_email"]} is already in use."}}
    end # end of checking if the email exists
  end # end of register user

  # register_user for a freelancer
  def register_user(:practise, params) do
    # ensure there is not user with the given email address
    if not user_exists?(params["auth_email"]) do
      # create a new user
      with {:ok, user} <- Accounts.create_user(params) do
        # ceate a new profile user from the account user
        profile_user = Profiles.profile_user_from_account_user(user)
        # start a ask for creating a new work profile
        Task.start(fn ->
          Ecto.build_assoc(profile_user, :work_profiles)
          # insert the work profile
          |> Repo.insert!()
        end)

        # create a user profile account for the user only after the user has being successfully created.
        Ecto.build_assoc(profile_user, :user_profile, %{emails: [user.auth_email]})
        # save the profile
        |> Repo.insert!()
        # return the user
        {:ok, user}
      end # end of eith for creating a new user

    else
      # user exists
      {:error, :email_exists, %{message: "Failed. The email address #{params["auth_email"]} is already in use."}}
    end # end of checking if the account exists
  end # end of registering a user for a practise

  @doc """
    Verifies an account and returns the details with the account
  """
  def verify_account(%User{} = user, activation_key) when is_integer(activation_key) do
    # start a task for getting the profile with the smae id as the current user
    profile_task = Task.async(fn ->
      from(
        profile in UserProfile,
        where: profile.user_id == ^user.id
      )
      # get the profile
      |> Repo.one!()
    end)
    # check if the verification key entered by the user and the one stored in the system are equal
    if user.activation_key !== activation_key do
      # return an error
      {:error, :invalid_activation_key}
    else
      # update the activation to true
      with {:ok, user} <- user |> Ecto.Changeset.change(%{is_active: true}) |> Repo.update() do
        # load the user who has the smae id as the is as the one with the current user
        profile = Task.await(profile_task)
        # return the user
        {:ok, %{
          user: user,
          user_profile: profile
        }}
      end # end of with for activating the account
    end # end of with for updating the account
  end # end of the verify accounts

  @doc """
    Updates the location of a user profile
  """
  def update_user_profile_location(%User{} = user, profile_id, location_params) do
    # get the profile with the given id
    profile = Profiles.get_user_profile!(profile_id)
    # ensure the current user is the owner of the profile
    if profile.user_id == user.id do
      # update the profile and return the profile
      with {:ok, _profile} = result <- Profiles.update_user_profile_location(profile, location_params), do: result
    else
      # the current user is not the owner of the profile
      # return the result
      {:error, :not_owner}
    end # end of the if
  end # end of update_profile_location/2

  @doc """
    Updates a user's profile email address
  """
  def update_user_profile_emails(%User{} = user, profile_id, new_email) do
    # get the profile
    profile = Profiles.get_user_profile!(profile_id)
    # ensure the user is the owner of the profile
    if profile.user_id == user.id do
      # update the email
      with {:ok, _profile} = result <- Profiles.update_user_profile_email(profile, %{email: new_email}), do: result
    else
      # the user is not the owner
      {:error, :not_owner}
    end # end of checking if the user is the owner
  end #  end of the update_profile_emails

  @doc """
    Updates a user's profile phone number
  """
  def update_user_profile_phones(%User{} = user, profile_id, new_phone) do
    # get the profile
    profile = Profiles.get_user_profile!(profile_id)
    # ensure the user is the owner of the profile
    if profile.user_id == user.id do
      # update the email
      with {:ok, _profile} = result <- Profiles.update_user_profile_phone(profile, %{phone: new_phone}), do: result
    else
      # the user is not the owner
      {:error, :not_owner}
    end # end of checking if the user is the owner
  end #  end of the update_profile_emails


  @doc """
    Updates the skills of a given user
  """
  def update_work_profile_skills(%User{} = user, profile_id, new_skills) do
    # get the work profile
    work_profile = Profiles.get_work_profile!(profile_id)
    # ensure the user is the owner of the work profile
    if work_profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Profiles.update_work_profile_skills(work_profile, %{skills: new_skills}) do
        # return the result
        result
        # there are no changese
      else
        :no_changes ->
          # return the profile as is
          {:ok, work_profile}
      end # end of with

    else
      # the user is not the owner
      {:error, :not_owner}
    end # end of the checking if current user is the owner of the profile
  end # end of the update_profile_skills


  @doc """
    Updates a user's professional introduction
  """
  def update_work_profile_prof_intro(%User{} = user, profile_id, prof_intro) do
    # get the work profiel with the given id
    work_profile = Profiles.get_work_profile!(profile_id)
    # ensure the current user is the owner of the profile
    if work_profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Profiles.update_work_profile_prof_intro(work_profile, %{professional_intro: prof_intro}), do: result

    else
      # the user is not the owner of the job
      {:error, :not_owner}
    end # end of checking whether the current user is the owner of the profile
  end # end of the update_work_profile_prof_intro/2

  @doc """
    Updates a user's cover letter
  """
  def update_work_profile_cover_letter(%User{} = user, profile_id, cover_letter) do
    # get the work profiel with the given id
    work_profile = Profiles.get_work_profile!(profile_id)
    # ensure the current user is the owner of the profile
    if work_profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Profiles.update_work_profile_cover_letter(work_profile, %{cover_letter: cover_letter}), do: result

    else
      # the user is not the owner of the job
      {:error, :not_owner}
    end # end of checking whether the current user is the owner of the profile
  end # end of the update_work_profile_prof_intro/2


  alias Eworks.Orders
  alias Eworks.Orders.{Order, OrderOffer}
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
  def update_order_payment(%User{} = user, order_id, payment_params) do
    # get the order with the given id
    order = Orders.get_order!(order_id)
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
  def update_order_duration(%User{} = user, order_id, duration_params) do
    # get the order with the given id
    order = Orders.get_order!(order_id)
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
  def update_order_type_and_contractors(%User{} = user, order_id, type_params) do
    # get the order with the given id
    order = Orders.get_order!(order_id)
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
  def update_order_description(%User{} = user, order_id, description) do
    # get the order with the given id
    order = Orders.get_order!(order_id)
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
    Submits an offer
  """
  def submit_order_offer(%User{} = user, order_id, asking_amount) do
    # check if the user is a client or not
    if user.user_type == "Client" do
      # return an error
      {:error, :is_client}
    else
      # create a task for creating the offer
      Task.start(fn ->
        # get the order with the specified id
        with {:ok, order} <- Orders.get_order(order_id) do
          # create a new order
          user
          # add the user id and the order id
          |> Ecto.build_assoc(:order_offers, %{order_id: order.id, asking_amount: asking_amount})
          # create the offer
          |> Repo.update!()
        end # end of with for getting the order
      end)
      # return ok
      :ok
    end # end of checking if the user is a client
  end # end of submitting an order offer

  @doc """
  Functions for rejecting an order offer
  """
  def reject_order_offer(order_offer_id) do
    Task.start(fn ->
      # get the order_offer with the given id
      offer = Orders.get_order_offer!(order_offer_id)
      # check if the offer has been cancelled or not
      with :true <- offer.is_pending, order_offer <- offer |> Ecto.Changeset.change(%{is_accepted: true}) |> Repo.update!() do
        # broadcast to the user in realtime that the offer has being decline
        order_offer
      end
    end)
    # return :ok
    :ok
  end # end of the reject offer


  defp accept_offer(offer, ) do
    # check if the offer is cancelled or not
    if not offer.is_cancelled do
      # update the offer
      offer
      # put the is_accepted to true and set the is_pending to false
      |> Ecto.Changeset.change(%{
        :is_accepted: true,
        :is_pending: false
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

  @doc """
    Function that accepts an order
  """
  def accept_order_offer(%User{} = user, order_id, order_offer_id) do
    # start the task for getting the offer
    offer_task = Task.async(fn ->
      Orders.get_order_offer!(order_offer_id)
    end)
    # get the order
    order = Orders.get_order!(order_id)
    # check if the current user is the owner of the job
    if order.user_id == user.id do
      # update the offer
      case accept_offer(Task.await(offer_task)) do
        # offer successfully accepted
        :ok ->
          # update the order by reducing the number of required offers by 1 and return the order
          if order.accepted_offers == 3 do
            order
            # reduce the number of required contractors
            |> Ecto.Changeset.change(%{
              required_contractors: order.required_contractors - 1
            })
            # update the order
            |> Repo.update!()
            # get the bid for which the user has accepted
            |> Repo.preload(:order_offers, [
              from(
                offer in OrderOffer,
                where: offer.is_accepted == true
              )
            ])
          else
            # the user still can accept other offers
            order
            # reduce the number of required contractors
            |> Ecto.Changeset.change(%{
              required_contractors: order.required_contractors - 1
            })
            # update the order
            |> Repo.update!()
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
  def assign_order(%User{} = user, order_id, to_assign_id) do
    # get the person to be assigned
    to_assignee_task = Task.async(fn ->
      Accounts.get_user!(to_assign_id) |> preload([
        # preload the work profile and return the full name and the professional intro
        work_profile: from profile in WorkProfile, select: [profile.full_name, profile.professional_intro],
        # preload the order offer made for this particular offer
        order_offers: from offer in OrderOffer, where: offer.order_id == ^order_id, select: [offer.asking_amount]
      ])
    end)
    # get the order
    order = Orders.get_order!(order_id)
    # check if the job has being assigned
    if not order.is_assigned and order.already_assigned != order.required_contractors do
      Task.start(fn ->
        # update the user and add the current order to the user's assigned orders
        order
        # add the order id to the user's assigned orders
        |> Ecto.build_assoc(:assigned_orders)
        # update the user
        |> Repo.update!()

        # send notification to the user about the assigned orders
      end)

      
    else
      # the order has already being assigned
      {:error, :already_assigned}
    end # end of checking whether the order has already been assigned or the required contractors have been met

  end # end of assigning an order

  # def authenticate_user(%User{auth_email: email, password_hash: pass} = user) do
  #   # get the user with the email address
  #   Accounts.get_user_by_email!(email)

  # rescue
  #   # user with given email address does not exist
  #   Ecto.NoResultsError ->
  #     {:error, :user_not_found}
  # end # end of the authenticate user

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

end
