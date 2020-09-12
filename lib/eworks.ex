defmodule Eworks do
  @moduledoc """
  Eworks keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Eworks.{Accounts}
  alias Eworks.Repo
  alias Eworks.Accounts.{User}

  @doc """
    Creates a user account and also the profile for the account
  """
  def register_user(params) do
    # create the user
    with {:ok, user} <- Accounts.create_user(params) do
      # create a profile account for the user only after the user has being successfully created.
       Ecto.build_assoc(user, :profile, %{emails: [user.auth_email]})
       # save the profile
       |> Repo.insert!()
      # return the user
      {:ok, user}
    end
  end # end of register user

  @doc """
    Verifies an account and returns the details with the account
  """
  def verify_account(%{user_id: id, activation_key: key} = _params) do
    # get user with the given key
    user = Accounts.get_user!(id)
    # check if the verification key entered by the user and the one stored in the system are equal
    if user.activation_key !== key do
      # return an error
      {:error, :invalid_activation_key}
    else
      # update the activation to true
      with {:ok, user} <- user |> Ecto.Changeset.change(%{is_active: true}) |> Repo.update() do
        # prealod the profile for the user
        user = Repo.preload(user, :profile)
        # return the user
        {:ok, user}
      end # end of with for activating the account
    end # end of with for updating the account
  rescue
    # the user with the given id doeas not exist
    Ecto.NoResultsError ->
      # return error
      {:error, :not_found}
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
