defmodule Eworks do
  @moduledoc """
  Eworks keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Eworks.{Accounts, Orders}
  alias Eworks.Repo

  @doc """
    Creates a user account and also the profile for the account
  """
  def register_user(params) do
    # create the user
    with {:ok, user} <- Accounts.create_user(params) do
      # create a profile account for the user only after the user has being successfully created.
      _profile = user |> Ecto.build_assoc(:profile, %{emails: [user.auth_email]}) |> Repo.insert!()
      # preload the user to return the user with the profile details
      user = Repo.preload(user, :profile)
      # return the user
      {:ok, user}
    end
  end # end of register user

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
