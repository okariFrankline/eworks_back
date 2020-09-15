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
    end # end of checking if the account exists

  else
    # user exists
    {:error, :email_exists, %{message: "Failed. The email address #{params["auth_email"]} is already in use."}}
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
  def update_work_profile_skills(%Users{} = user, profile_id, new_skills) do
    # get the work profile
    profile = Profiles.get_work_profile!(profile_id)
    # ensure the user is the owner of the work profile
    if profile.user_id == user.id do
      # update the profile
      with {:ok, _profile} = result <- Profiles.update_work_profile_skills(profile, %{skills: new_skills}) do
        # return the result
        result
        # there are no changese
      else
        :no_changes ->
          # return the profile as is
          {:ok, profile}
      end # end of with
    end # end of the checking if current user is the owner of the profile
  end # end of the update_profile_skills

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
