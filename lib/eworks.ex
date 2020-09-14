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

  @doc """
    Creates a user account and also the profile for the account
  """
  def register_user(params) do
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
  end # end of register user

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
